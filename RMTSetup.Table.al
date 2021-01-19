Table 51102 "RMT Setup"
{
    Caption = 'RMT Setup';

    fields
    {
        field(1; PrimaryKey; Text[30])
        {
        }
        field(2; "EFT Creation Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(3; "EFT Export Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(4; "EFT Re-Export Batch"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5; "Store Requisition Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(6; "Archive Store Requisition"; Boolean)
        {
        }
        field(7; "Purchase Requisition Nos"; Code[10])
        {
            Caption = 'Purchase Requisition Nos.';
            TableRelation = "No. Series";
        }
        field(8; "Archive Purch. Requisition"; Boolean)
        {
        }
        field(9; "Store Req Item Jnl Template"; Code[10])
        {
            TableRelation = "Item Journal Template";
        }
        field(10; "Store Req Item Jnl Batch"; Code[10])
        {

            trigger OnLookup()
            var
                frmBatchList: Page "Item Journal Batches";
                lvItemJnlBatch: Record "Item Journal Batch";
            begin
                Clear(frmBatchList);
                lvItemJnlBatch.SetRange(lvItemJnlBatch."Journal Template Name", "Store Req Item Jnl Template");
                lvItemJnlBatch.SetRange(lvItemJnlBatch."Template Type", lvItemJnlBatch."template type"::Item);
                frmBatchList.SetRecord(lvItemJnlBatch);
                frmBatchList.SetTableview(lvItemJnlBatch);
                frmBatchList.LookupMode(true);
                if frmBatchList.RunModal = Action::LookupOK then begin
                    frmBatchList.GetRecord(lvItemJnlBatch);
                    "Store Req Item Jnl Batch" := lvItemJnlBatch.Name;
                end;
                Clear(frmBatchList);
            end;
        }
        field(11; "Store Req. Validity Period"; DateFormula)
        {
        }
        field(12; "Purch. Req. Validity Period"; DateFormula)
        {
        }
        field(14; "Purch. Order Validity Period"; DateFormula)
        {
        }
        field(15; "Sales Quote Validity Period"; DateFormula)
        {
        }
        field(17; "Bank Batch No. Series"; Code[11])
        {
            TableRelation = "No. Series";
        }
        field(21; "Bulk Receipt No Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(29; "Store Req. Archive No. Series"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(30; "Bulk Invoice No Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(32; "Store Return Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(33; "Store Return Item Jnl Template"; Code[10])
        {
            TableRelation = "Item Journal Template" where(Type = const(Item));
        }
        field(34; "Store Return Item Jnl Batch"; Code[10])
        {

            trigger OnLookup()
            var
                frmBatchList: Page "Item Journal Batches";
                lvItemJnlBatch: Record "Item Journal Batch";
            begin
                Clear(frmBatchList);
                lvItemJnlBatch.SetRange(lvItemJnlBatch."Journal Template Name", "Store Return Item Jnl Template");
                lvItemJnlBatch.SetRange(lvItemJnlBatch."Template Type", lvItemJnlBatch."template type"::Item);
                frmBatchList.SetRecord(lvItemJnlBatch);
                frmBatchList.SetTableview(lvItemJnlBatch);
                frmBatchList.LookupMode(true);
                if frmBatchList.RunModal = Action::LookupOK then begin
                    frmBatchList.GetRecord(lvItemJnlBatch);
                    "Store Return Item Jnl Batch" := lvItemJnlBatch.Name;
                end;
                Clear(frmBatchList);
            end;
        }
        field(35; "Store Return Validity Period"; DateFormula)
        {
        }
        field(36; "Store Return Archive No series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(37; "Create Purch Req from Req Wksh"; Boolean)
        {
        }
        field(40; "No. Of Quotes From Purch. Req"; Integer)
        {
        }
        field(41; "Store Req. Whse Jnl Template"; Code[20])
        {
            TableRelation = "Warehouse Journal Template" where(Type = const(Item));
        }
        field(42; "Store Req. Whse Jnl Batch"; Code[20])
        {
            TableRelation = "Warehouse Journal Batch".Name where("Journal Template Name" = field("Store Req. Whse Jnl Template"),
                                                                  "Template Type" = const(Item));
        }
        field(51; "Purch. Quote By Requis. Amount"; Boolean)
        {
        }
        field(52; "Request For Quotation Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(53; "Archive RFQ Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(54; "Service Quote Validity Period"; DateFormula)
        {
        }
        field(55; "RFQ Sender E-Mail"; Text[50])
        {
        }
        field(56; "Unbudgeted PR No"; Code[10])
        {
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

