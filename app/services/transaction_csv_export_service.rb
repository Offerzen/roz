require 'csv'

class TransactionCsvExportService
  def initialize(transactions, csv_format)
    @transactions = transactions
    @csv_format = csv_format
  end

  def self.generate_csv!(transactions, csv_format)
    new(transactions, csv_format).generate_csv!
  end

  def generate_csv!
    if csv_format_is_cash_report?
      generate_cash_report_csv!
    else
      generate_sage_report_csv!
    end
  end

  private

  attr_reader :transactions, :csv_format

  def generate_cash_report_csv!
    ::CSV.generate do |writer|
      writer << cash_report_headers

      transactions.each do |transaction|
        writer << [
          transaction.date.strftime('%Y/%m/%d'),
          nil, # Service Fee: Left blank for now
          transaction.amount,
          transaction.description || 'No Description',
          nil, # Reference: Left blank for now
          nil, # Balance: Left blank for now
          transaction.budget_category&.name || 'Uncategorized',
          transaction.team.name,
          transaction.team.group
        ]
      end
    end
  end

  def generate_sage_report_csv!
    ::CSV.generate do |writer|
      writer << sage_report_headers

      transactions.each do |transaction|
        writer << [
          transaction.date.strftime('%Y/%m/%d'),
          transaction.description || 'No Description',
          transaction.amount
        ]
      end
    end
  end

  def cash_report_headers
    ['Effective Date', 'SERVICE FEE', 'AMOUNT', 'DESCRIPTION', 'REFERENCE', 'BALANCE', 'MAPPING', 'Team', 'Group']
  end

  def sage_report_headers
    ['Date', 'Description', 'Amount']
  end

  def csv_format_is_cash_report?
    csv_format == :cash_report
  end
end
