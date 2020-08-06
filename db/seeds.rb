require 'faker'

finops = Team.create!(name: "FinOps", slack_id: ENV['SLACK_TEST_NOTIFICATIONS'], group: 'FinOps Group', default: true)
product = Team.create!(name: "Product", slack_id: ENV['SLACK_TEST_NOTIFICATIONS'], group: 'Product Group')

# admin
admin = User.create!(role: "team_lead", team: finops, name: Faker::Name.first_name, slack_id: 'admin', email: Faker::Internet.email, admin: true)

3.times do
  first_name = Faker::Name.first_name 
  last_name = Faker::Name.last_name 
  user = User.create!(role: "team_member", slack_id: first_name, team: finops, name: "#{first_name} #{last_name}", email: Faker::Internet.email)
end

[
  "Professional fees (Consulting, Insurance etc)",
  "Subscriptions",
  "Courier, Postage & Delivery",
  "Marketing Events Costs",
  "Food & Snacks",
  "Furniture & Equipment",
  "Telephone & Internet",
  "Repairs & Maintenance",
  "Office Services",
  "Online Ads",
  "Parking",
  "Printing & Stationery",
  "Sponsorship",
  "Team Entertainment",
  "Staff Events",
  "Training",
  "Travel International - Accommodation",
  "Travel International - Food & Entertainment",
  "Travel International - Transport",
  "Travel Local - Accommodation",
  "Travel Local - Food & Entertainment",
  "Travel Local - Transport"
].each do |name|
  BudgetCategory.create! name: name
end

# Finops only categories
[
  "Bank Charges",
  "Bonuses",
  "Contract Work",
  "Deposit Refund",
  "Fraud Transactions",
  "Interest Received",
  "Lumpsum Fees",
  "Monthly Fees",
  "PAYE",
  "Rent",
  "Security",
  "Salaries",
  "Subscription Fees",
  "VAT"
].each do |name|
  BudgetCategory.create! name: name, special: true
end

user = User.where(admin: false).first

finop_subs = ['SAGE', 'Xero', 'ReceiptBank', 'Pastel']
product_subs = ['GitHub', 'Heroku', 'DataDog']

general_descriptions = ['Pony Rental', 'Now Now', 'Deluxe Coffee', 'Electricity']
no_card_descriptions = ['Interest', 'Bank charges']

finops_card = Card.create!(number: '4000000000000001', team: finops)
finops_card2 = Card.create!(number: '4000000000000004', team: finops)
product_card = Card.create!(number: '4000000000000002', team: product)
user_card = Card.create!(number: '4000000000000003', user: user, team: finops)

# product transactions
product_subs.each do |subscription|
  Transaction.create!(amount_currency: 'ZAR', team: product, description: subscription, budget_category: BudgetCategory.find_by(name: "Subscriptions"), amount_cents: -rand(10_000_00), card: product_card, confirmation_state: 'confirmed', confirmed_by: admin, date: rand(10).days.ago.beginning_of_day)
end

# recent transactions
10.times do
  Transaction.create!(amount_currency: 'ZAR', team: product, budget_category: BudgetCategory.all.sample, amount_cents: -rand(10_000_00), card: product_card, confirmation_state: 'confirmed', confirmed_by: admin, date: rand(29).days.ago.beginning_of_day, description: general_descriptions.sample)
end

# older transactions
10.times do
  Transaction.create!(amount_currency: 'ZAR', team: product, budget_category: BudgetCategory.all.sample, amount_cents: -rand(10_000_00), card: product_card, confirmation_state: 'confirmed', confirmed_by: admin, date: (31 + rand(20)).days.ago.beginning_of_day, description: general_descriptions.sample)
end

# finops transactions
finop_subs.each do |subscription|
  Transaction.create!(amount_currency: 'ZAR', team: finops, description: subscription, budget_category: BudgetCategory.find_by(name: "Subscriptions"), amount_cents: -rand(10_000_00), card: finops_card, confirmation_state: 'confirmed', confirmed_by: admin, date: rand(10).days.ago.beginning_of_day)
end

# finops transactions without description
2.times do
  Transaction.create!(amount_currency: 'ZAR', team: finops, budget_category: BudgetCategory.all.sample, amount_cents: -rand(10_000_00), card: finops_card, date: rand(10).days.ago.beginning_of_day)
end

# finops uncategorized transactions
2.times do
  Transaction.create!(description: general_descriptions.sample, amount_currency: 'ZAR', team: finops, budget_category: nil, amount_cents: -rand(10_000_00), card: finops_card, date: rand(10).days.ago.beginning_of_day)
end

# user transactions
3.times do
  Transaction.create!(amount_currency: 'ZAR', team: finops, user: user, description: general_descriptions.sample, budget_category: BudgetCategory.all.sample, amount_cents: -rand(10_000_00), card: user_card, confirmation_state: 'confirmed', confirmed_by: user, date: rand(10).days.ago.beginning_of_day)
end

# user transactions without confirmation
2.times do
  Transaction.create!(amount_currency: 'ZAR', team: finops, user: user, description: general_descriptions.sample, budget_category: BudgetCategory.all.sample, amount_cents: -rand(10_000_00), card: user_card, date: rand(10).days.ago.beginning_of_day)
end

# no card transactions
5.times do
  Transaction.create!(amount_currency: 'ZAR', description: no_card_descriptions.sample, budget_category: BudgetCategory.all.sample, amount_cents: rand(10_000_00), date: rand(10).days.ago.beginning_of_day, team: finops)
end
