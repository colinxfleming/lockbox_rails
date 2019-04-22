require 'rails_helper'

describe LockboxPartner, type: :model do
  it { is_expected.to have_many(:users) }

  describe '#balance' do
    let(:lockbox) { FactoryBot.create(:lockbox_partner) }

    let(:start_date) { Date.current - 2.months }

    let(:add_cash) do
      LockboxAction.create!(
        action_type:     'add_cash',
        status:          'pending',
        eff_date:        start_date,
        lockbox_partner: lockbox
      ).tap do |action|
        action.lockbox_transactions.create!(
          amount_cents: 1000_00,
          eff_date: start_date,
          balance_effect: 'credit'
        )
      end
    end

    def pending_request_on(date)
      lockbox.lockbox_actions.create!(
        action_type: 'client_support',
        status:      'pending',
      )
    end

    context 'have only added cash but no support requests yet' do
      before { add_cash }

      it 'returns the amount of the initial cashbox deposit' do
        expect(lockbox.balance).to eq(1000.to_money)
      end

      context 'excluding pending' do
        it 'returns 0' do
          expect(lockbox.balance(exclude_pending: true)).to eq(Money.zero)
        end

        context 'add cash was completed' do
          before { add_cash.complete! }

          it 'returns the 1000' do
            expect(lockbox.balance(exclude_pending: true)).to eq(1000.to_money)
          end
        end
      end
    end

    context 'add cash, multiple pending & completed actions' do
      before { add_cash }

    end
  end
end