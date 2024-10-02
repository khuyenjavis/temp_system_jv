# frozen_string_literal: true

class ChangeNamePaymentIdToInvoices < ActiveRecord::Migration[7.0]
  def change
    rename_column :invoices, :payment_id, :payment_intent_id
  end
end
