## MVP for First Release

**MAC User**

As a MAC user (coordinator or finance), I can...

- Add a new LockboxPartner to the app
- Add cash to a LockboxPartner's cashbox by filling out a form in the app (can also edit the add cash lockbox action)
- Create a SupportRequest for a LockboxPartner to set aside a certain amount of cash for a client on a given date
- See a dashboard of all Support Requests across LockboxPartners** (need to define what dashboard looks like and how many filters there are)
- See an invidivual LockboxPartner lockbox
  - includes ability to add cash
  - includes lockbox action history / support request history
  - includes balance
- View and edit an individual SupportRequest
- Add a note to a SupportRequest
- Receive a notification email that a reconciliation mismatch occurred

**Partner User**

As a LockboxPartner, I can...

- View alerts in app prompting me to confirm receipt of cash added to the box OR reconcile the lockbox
- Confirm that I have received cash in my Lockbox by clicking a button
- Reconcile the lockbox by completing a webform asking for the amount in the lockbox
- Receive a notification email that a new support request exists for my lockbox
- View all of my support requests (auto filter to 'pending' status but ability to view all historical)
- View details for one support request
- Update status of support request's lockbox action to completed or canceled with option to edit the amount and pickup date
- Add notes to a support request

## User Stories

**Lockbox Partners**

- As a lockbox partner, I would like to log updated cash amount in the lockbox so that the system reflects the updated cash value
- As a lockbox partner, I would like update that lockbox so that I can reflect whether a client got the cash and record any discrepancies
- As a clinic partner, I would like to reconcile the lockbox so that the physical money in the lockbox matches our lockbox app records

**MAC Finance User**
- As a MAC finance user, I would like to receive notification when balance in a lockbox drops below $300 threshold so that I know I need to send more money to the clinic 
- As a MAC finance user, I would like to log in and view the lockbox balance and history at each clinic so that I have information for reporting
- As a MAC finance user, I would like to add a clinic partner to the lockbox so that they can start distributing MAC cash to clients

**MAC Coordinator**

- As a MAC coordinator, I would like to make a lockbox request to notify a clinic so that the clinic knows to set aside X amount money for a client on a particular date
- Coordinator is able to modify the subject line of the notification email so that the clinic knows if the case is urgent (i.e. “THERE TODAY”)
- As a MAC coordinator, I would like to receive a notification when a clinic completes a lockbox request so that I’m up-to-date with my client’s progress

## Core models

**User**

- Devise auth stuff
- Email
- Name
- clinic/partner/lockbox id

**Lockbox Partner**

- Has many users
- Name
- Address
- Phone number
- Has many lockbox actions
- Has many lockbox transactions (through lockbox action)

**Support Request**

- Client Ref ID (UUID)
- Client Name/Alias
- Urgency flag (“THERE NOW”)
- Belongs to a Lockbox Partner
- Has many notes

**Notes** (polymorphic)

- Belongs to support request
- Belongs to user (author)
- Text

**Lockbox Actions**

- Eff date
- Action Type
  - Adding Cash
  - Reconciling
  - Client Support
- Status
  - Pending ($$ has been requested but not disbursed)
  - Completed ($$ has been disbursed to client)
  - Canceled (Client no longer needs $$, nothing disbursed)
- Resolved At (logs the date the Lockbox Action was completed/canceled)
- Belongs to a Lockbox Partner
- Belongs to a Support Request
- Has many accounting events

**Lockbox Transactions**
- Belongs to Lockbox Action
- Belongs to Clinic (through Lockbox Action)
- Eff date
- Type (debit or credit)
- Category
  - Gas
  - Parking
  - Transit
  - Childcare
  - Meds
  - Food
  - Adjustment
- Amount

## Balance Calculation Logic

Sum of all accounting line items for a given clinic up to a certain date MINUS the amount of pending transactions if that particular date is in the future

**Edge Cases**
What happens when a coordinator creates a request for an amount that is not fully present in the LB?

- Allow the request to be created
- Balance drops to negative
- Fires off alerts/notifications to MAC finance and coordinators
- Adding cash or canceling the request will resolve


## Workflows

**New clinic**

- Finance/lockbox admin: Provision new lockbox (intake clinic)
- Finance/lockbox admin: Send a check in the mail with a physical box to clinic
- Clinic takes action: log that they received the check

**Client request**

- From coordinator: This person is coming on this date and needs this money (line item expenses)
Notes
- Clinic receives request 
- See edge cases for “overdrawing”
- Clinic sets aside funds (pending) 
- Clinic distributes funds (completed)

**Reconcile**

- Once a month, clinic logs how much money is currently in box
- Adjustments
