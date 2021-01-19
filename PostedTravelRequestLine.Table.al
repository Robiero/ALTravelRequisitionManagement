Table 50068 "Posted Travel Request Line"
{

    fields
    {
        field(1; "Document No."; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; "Employee No."; Code[20])
        {
        }
        field(4; "Employee Name"; Text[100])
        {
        }
        field(5; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Accomodation,Travel,Per Diem';
            OptionMembers = " ",Accomodation,Travel,"Per Diem";
        }
        field(6; Description; Text[50])
        {
        }
        field(7; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(8; Status; Option)
        {
            OptionCaption = 'Open,Disbursed,Accounted,Refunded,Reimbursed,UnAccounted';
            OptionMembers = Open,Disbursed,Accounted,Refunded,Reimbursed,UnAccounted;
        }
        field(9; "Transaction Date"; Date)
        {
        }
        field(10; Location; Code[10])
        {
            TableRelation = Location;
        }
        field(11; Department; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = filter(1));
        }
        field(12; Quantity; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Unit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Total Amount"; Decimal)
        {
        }
        field(20; "Travel Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Travel From"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Travel To"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Departure Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Arrival Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Flight No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "PerDiem Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,MEALS,TRANSPORT,OUT OF POCKET';
            OptionMembers = " ",MEALS,TRANSPORT,"OUT OF POCKET";
        }
        field(30; "Account Type"; Option)
        {
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account';
            OptionMembers = "G/L Account",Customer,Vendor,"Bank Account";
        }
        field(31; "Account No."; Code[20])
        {
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account" where("Income/Balance" = const("Income Statement"))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account";
        }
        field(32; "External Document No."; Code[20])
        {
        }
        field(33; "Authorised By"; Code[30])
        {
            TableRelation = "User Setup";
        }
        field(34; "Journal Document No."; Code[20])
        {
        }
        field(36; "Bal. Account Type"; Option)
        {
            OptionMembers = "G/L Account",Customer,Vendor,"Bank Account";
        }
        field(37; "Bal. Account No."; Code[20])
        {
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";
        }
        field(38; "Board Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,BB,HB';
            OptionMembers = " ",BB,HB;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Total Amount";
        }
    }

    fieldgroups
    {
    }
}

