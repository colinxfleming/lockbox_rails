# frozen_string_literal: true

class LockboxTransaction < ApplicationRecord
  monetize :amount_cents

  belongs_to :lockbox_action

  validates :amount_cents, :numericality => { :greater_than_or_equal_to => 0 }

  BALANCE_EFFECTS = [
    DEBIT  = 'debit',
    CREDIT = 'credit'
  ].freeze

  EXPENSE_CATEGORIES = [
    GAS        = 'gas',
    PARKING    = 'parking',
    TRANSIT    = 'transit',
    CHILDCARE  = 'childcare',
    MEDICINE   = 'medicine',
    FOOD       = 'food',
    ADJUSTMENT = 'adjustment'
  ].freeze

  def eff_date
    lockbox_action.eff_date
  end
end
