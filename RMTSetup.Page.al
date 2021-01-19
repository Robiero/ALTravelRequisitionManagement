Page 51113 "RMT Setup"
{
    PageType = List;
    SourceTable = "RMT Setup";

    layout
    {
        area(content)
        {
            group(Numbering)
            {
                Caption = 'Numbering';
                field(Control1102754018; "Bulk Receipt No Series")
                {
                    ApplicationArea = Basic;
                    Caption = 'Bulk Receipt No. Series';
                }
                field(EFTCreationBatch; "EFT Creation Batch")
                {
                    ApplicationArea = Basic;
                }
                field(EFTExportBatch; "EFT Export Batch")
                {
                    ApplicationArea = Basic;
                }
                field(EFTReExportBatch; "EFT Re-Export Batch")
                {
                    ApplicationArea = Basic;
                }
                field(BankBatchNoSeries; "Bank Batch No. Series")
                {
                    ApplicationArea = Basic;
                }
                field(StoreRequisitionNos; "Store Requisition Nos")
                {
                    ApplicationArea = Basic;
                }
                field(StoreReqArchiveNoSeries; "Store Req. Archive No. Series")
                {
                    ApplicationArea = Basic;
                }
                field(PurchaseRequisitionNos; "Purchase Requisition Nos")
                {
                    ApplicationArea = Basic;
                }
                field(BulkInvoiceNoSeries; "Bulk Invoice No Series")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field(StoreReturnNos; "Store Return Nos")
                {
                    ApplicationArea = Basic;
                }
                field(StoreReturnArchiveNoseries; "Store Return Archive No series")
                {
                    ApplicationArea = Basic;
                }
                field(RequestForQuotationNos; "Request For Quotation Nos.")
                {
                    ApplicationArea = Basic;
                }
                field(ArchiveRFQNos; "Archive RFQ Nos.")
                {
                    ApplicationArea = Basic;
                }
                field(StoreReqItemJnlTemplate; "Store Req Item Jnl Template")
                {
                    ApplicationArea = Basic;
                }
                field(StoreReqItemJnlBatch; "Store Req Item Jnl Batch")
                {
                    ApplicationArea = Basic;
                }
                field(StoreReturnItemJnlTemplate; "Store Return Item Jnl Template")
                {
                    ApplicationArea = Basic;
                }
                field(StoreReturnItemJnlBatch; "Store Return Item Jnl Batch")
                {
                    ApplicationArea = Basic;
                }
                field(UnbudgetedPRNo; "Unbudgeted PR No")
                {
                    ApplicationArea = Basic;
                }
            }
            group(Requisition)
            {
                Caption = 'Requisition';
                field(ArchivePurchRequisition; "Archive Purch. Requisition")
                {
                    ApplicationArea = Basic;
                }
                field(CreatePurchReqfromReqWksh; "Create Purch Req from Req Wksh")
                {
                    ApplicationArea = Basic;
                }
                field(RFQSenderEMail; "RFQ Sender E-Mail")
                {
                    ApplicationArea = Basic;
                }
            }
            group(DocumentValidity)
            {
                Caption = 'Document Validity';
                field(StoreReqValidityPeriod; "Store Req. Validity Period")
                {
                    ApplicationArea = Basic;
                }
                field(PurchReqValidityPeriod; "Purch. Req. Validity Period")
                {
                    ApplicationArea = Basic;
                }
                field(PurchOrderValidityPeriod; "Purch. Order Validity Period")
                {
                    ApplicationArea = Basic;
                }
                field(SalesQuoteValidityPeriod; "Sales Quote Validity Period")
                {
                    ApplicationArea = Basic;
                }
                field(ServiceQuoteValidityPeriod; "Service Quote Validity Period")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

