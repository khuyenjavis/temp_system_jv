# frozen_string_literal: true

require 'json'
module V1
  class InvoiceApi < Grape::API
    before { authenticate! }

    resources :invoices do
      desc 'GET api/v1/invoices'
      params do
        optional :invoice_date
        optional :page, type: Integer, default: 1
        optional :per, type: Integer, default: 10
      end
      get do
        q = {}
        q[:invoice_date_eq] = params[:invoice_date] if params[:invoice_date].present?
        query = Invoice.ransack(q)
        query.sorts = 'created_at desc' if query.sorts.empty?
        invoices = query.result.page(params[:page]).per(params[:per])
        invoice_serializer = invoices.map do |invoice|
          InvoiceSerializer.new(invoice)
        end
        render_success(ResponseStatus::SUCCESS, I18n.t('invoices.list.success'), invoice_serializer.as_json, invoice)
      end

      desc 'GET api/v1/invoices/:id'
      params do
        requires :id, type: Integer, message: I18n.t('invoices.id.required')
      end
      get ':id' do
        invoice = invoice.find(params[:id])
        invoice_serializer = InvoiceSerializer.new(invoice)
        render_success(ResponseStatus::SUCCESS, I18n.t('invoices.detail.success'), invoice_serializer.as_json)
      end

      desc 'POST api/v1/invoices'
      params do
        requires :order_id, type: Integer, desc: 'Order ID'
        requires :shipping_first_name, type: String, desc: 'Shipping First Name'
        requires :shipping_middle_name, type: String, desc: 'Shipping Middle Name'
        requires :shipping_last_name, type: String, desc: 'Shipping Last Name'
        requires :shipping_email, type: String, desc: 'Shipping Email'
        requires :shipping_phone, type: String, desc: 'Shipping Phone Number'
        requires :shipping_alternative_number, type: String, desc: 'Shipping Alternative Phone Number'
        requires :shipping_city, type: String, desc: 'Shipping City'
        requires :shipping_street, type: String, desc: 'Shipping Street'
        requires :shipping_state, type: String, desc: 'Shipping State'
        requires :shipping_country, type: String, desc: 'Shipping Country'
        requires :shipping_zipcode, type: String, desc: 'Shipping Zipcode'
        optional :payment_date, type: String, desc: 'Payment Date'
        optional :invoice_date, type: String, desc: 'Invoice Date'
        optional :invoice_number, type: String, desc: 'Invoice Number'
        optional :status, type: String, desc: 'Status of the Invoice'
        optional :payment_type, type: String, desc: 'Payment Type'
        optional :subtotal, type: BigDecimal, desc: 'Order Sub-Total'
        optional :total, type: BigDecimal, desc: 'Order Total'
        optional :tax, type: BigDecimal, desc: 'Tax'
        optional :discount, type: BigDecimal, desc: 'Discount Applied'
        optional :shipping_cost, type: BigDecimal, desc: 'Shipping Cost'
      end
      post do
        invoice = Invoice.new(params_invoice)
        invoice.save!
        invoice_serializer = InvoiceSerializer.new(invoice)
        render_success(ResponseStatus::SUCCESS, I18n.t('invoices.create.success'), invoice_serializer)
      end

      desc 'PUT api/v1/invoices/:id'
      params do
        requires :id, type: Integer, message: I18n.t('invoices.id.required')
        optional :shipping_first_name, type: String, desc: 'Shipping First Name'
        optional :shipping_middle_name, type: String, desc: 'Shipping Middle Name'
        optional :shipping_last_name, type: String, desc: 'Shipping Last Name'
        optional :shipping_email, type: String, desc: 'Shipping Email'
        optional :shipping_phone, type: String, desc: 'Shipping Phone Number'
        optional :shipping_alternative_number, type: String, desc: 'Shipping Alternative Phone Number'
        optional :shipping_city, type: String, desc: 'Shipping City'
        optional :shipping_street, type: String, desc: 'Shipping Street'
        optional :shipping_state, type: String, desc: 'Shipping State'
        optional :shipping_country, type: String, desc: 'Shipping Country'
        optional :shipping_zipcode, type: String, desc: 'Shipping Zipcode'
        optional :payment_date, type: String, desc: 'Payment Date'
        optional :invoice_date, type: String, desc: 'Invoice Date'
        optional :invoice_number, type: String, desc: 'Invoice Number'
        optional :status, type: String, desc: 'Status of the Invoice'
        optional :payment_type, type: String, desc: 'Payment Type'
        optional :subtotal, type: BigDecimal, desc: 'Order Sub-Total'
        optional :total, type: BigDecimal, desc: 'Order Total'
        optional :tax, type: BigDecimal, desc: 'Tax'
        optional :discount, type: BigDecimal, desc: 'Discount Applied'
        optional :shipping_cost, type: BigDecimal, desc: 'Shipping Cost'
      end
      put ':id' do
        invoice = Invoice.find(params[:id])
        invoice.update!(params_invoice)
        invoice_serializer = InvoiceSerializer.new(invoice)
        render_success(ResponseStatus::SUCCESS, I18n.t('invoices.update.success'), invoice_serializer)
      end

      desc 'POST create payment indent'
      params do
      end
      post '/:id/payment' do
        invoice = Invoice.find(params[:id])
        service = Rails.application.config.payment_intent_service
        payment_intent =
          if invoice.payment_intent_id
            service.get_payment_intent(invoice)
          else
            payment_intent = service.create_payment_intent(invoice)
            invoice.update!(payment_intent_id: payment_intent.id)
            payment_intent
          end
        {
          client_secret: payment_intent.client_secret
        }
      end

      desc 'PUT update payment'
      params do
        optional :payment_intent_id, type: String
        optional :direct_payment, type: Boolean
      end
      put '/:id/payment' do
        invoice = Invoice.find_by(id: params[:id])
        invoice.blank? && render_error(I18n.t('invoices.not_found.messages'), ResponseStatus::NOT_FOUND)
        service = Rails.application.config.payment_intent_service
        if params[:direct_payment]
          if invoice.update(status: :paid, payment_date: Time.current, payment_type: :cash)
            render invoice
          else
            render_error(I18n.t('invoices.errors.messages'), ResponseStatus::UNPROCESSABLE_ENTITY)
          end
        else
          verify_payments = Invoice.where(payment_intent_id: params[:payment_intent_id])
          if verify_payments.present?
            render_error(I18n.t('invoices.payment.used'),
                         ResponseStatus::UNPROCESSABLE_ENTITY)
          end

          payment = service.get_payment_intent(params[:payment_intent_id])
          if payment.status == 'succeeded' && payment.amount.to_i == invoice.total.to_i
            if invoice.update(status: :paid, payment_date: Time.current, payment_intent_id: params[:payment_intent_id],
                              payment_type: :stripe)
              render json: invoice, serializer: InvoiceSerializer
            else
              render_error(I18n.t('invoices.errors.messages'), ResponseStatus::UNPROCESSABLE_ENTITY)
            end
          else
            render_error(I18n.t('invoices.payment.failed'), ResponseStatus::UNPROCESSABLE_ENTITY)
          end
        end
      rescue Stripe::StripeError => e
        render_error(I18n.t('invoices.payment.error', error: e.message), ResponseStatus::UNPROCESSABLE_ENTITY)
      end

      desc 'DELETE api/v1/invoices/:id'
      params do
        requires :id, type: Integer, message: I18n.t('invoices.id.required')
      end
      delete ':id' do
        invoice = Invoice.find(params[:id])
        invoice.destroy!
        render_success(ResponseStatus::SUCCESS, I18n.t('invoices.delete.success'), true)
      end
    end
    helpers do
      def params_invoice
        params.slice(:shipping_first_name, :shipping_middle_name, :shipping_last_name, :shipping_email, :shipping_phone,
                     :shipping_alternative_number, :shipping_city, :shipping_street, :shipping_state,
                     :shipping_country, :shipping_zipcode, :payment_date, :invoice_date, :invoice_number, :status, :payment_type,
                     :subtotal, :total, :tax, :discount, :shipping_cost)
      end
    end
  end
end
