Table 50066 "Travel Request Line"
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

            trigger OnValidate()
            begin
                GetTravelHeader;
                if "Entry Type" = "entry type"::Accomodation then begin
                    Quantity := TravelHeader."No. of Days";
                    "Board Type" := "board type"::" ";
                end;
            end;
        }
        field(6; Description; Text[50])
        {

            trigger OnValidate()
            begin
                Description := UpperCase(Description);
            end;
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

            trigger OnValidate()
            begin
                if "Employee No." = '' then begin
                    GetTravelHeader;
                    "Employee No." := TravelHeader."Employee No.";
                    "Employee Name" := TravelHeader."Employee Name";
                end;
            end;
        }
        field(13; "Unit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                GetEmployee;

                TravelGrade.Init;
                TravelGrade.SetRange(Code, Employee."Travel Grade");
                TravelGrade.SetRange("Currency Code", "Currency Code");
                if TravelGrade.FindFirst then;
                /*
                IF "Entry Type" = "Entry Type"::Accomodation THEN BEGIN
                  IF "Unit Amount" > TravelGrade."Max. Room Amt. Allowable" THEN
                    ERROR('The amount %1 shall exceed the allowable amount per day of %2.  Please amend the travel requisition line',"Unit Amount", TravelGrade."Max. Room Amt. Allowable");
                END ELSE*/
                if "Entry Type" = "entry type"::"Per Diem" then begin
                    if "PerDiem Type" = "perdiem type"::MEALS then begin
                        if "Unit Amount" > TravelGrade."Meals Amount" then
                            Error('The amount %1 shall exceed the meals allowable amount per day of %2.  Please amend the travel requisition line', "Unit Amount", TravelGrade."Meals Amount");
                    end else
                        if "PerDiem Type" = "perdiem type"::TRANSPORT then begin
                            if "Unit Amount" > TravelGrade."Transport Amount" then
                                Error('The amount %1 shall exceed the transport allowable amount per day of %2.  Please amend the travel requisition line', "Unit Amount", TravelGrade."Transport Amount");
                        end else
                            if "PerDiem Type" = "perdiem type"::"OUT OF POCKET" then begin
                                if "Unit Amount" > TravelGrade."Out of Pocket" then
                                    Error('The amount %1 shall exceed the out of pocket allowable amount per day of %2.  Please amend the travel requisition line', "Unit Amount", TravelGrade."Out of Pocket");
                            end;
                end;

                "Total Amount" := Quantity * "Unit Amount";

            end;
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
        field(39; Branch; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "line status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Open,Pending Approval,Approved,Disapproved,Canceled';
            OptionMembers = Open,"Pending Approval",Approved,Disapproved,Canceled;
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

    trigger OnInsert()
    begin
        GetTravelHeader;

        Location := TravelHeader.Location;
        "Currency Code" := TravelHeader."Currency Code";
        "Employee No." := TravelHeader."Employee No.";
        "Employee Name" := TravelHeader."Employee Name";
        Department := TravelHeader.Department;
        Branch := TravelHeader.Branch;
        "line status" := TravelHeader."HR Approval Status";
    end;

    trigger OnModify()
    begin

        "Currency Code" := TravelHeader."Currency Code";
        Department := TravelHeader.Department;
        Branch := TravelHeader.Branch;
        "line status" := TravelHeader."HR Approval Status";
    end;

    var
        TravelHeader: Record "Travel Request Header";
        TravelLine: Record "Travel Request Line";
        Text002: label 'Travel requisition %1 has lines that cannot be deleted.  Only open requisitions can be deleted.';
        Text003: label 'Travel requisition %1 has lines that cannot be modified.  Reset header and then modify requisition.';
        Text004: label 'Travel requisition %1 is not open and therefore no lines can be added.';
        UserSetup: Record "User Setup";
        Loc: Record Location;
        LocationCODE: Code[10];
        Employee: Record Employee;
        TravelGrade: Record "Employee Travel Grade";

    local procedure GetTravelHeader()
    begin
        TestField("Document No.");
        TravelHeader.SetRange("No.", "Document No.");
        if TravelHeader.FindFirst then;
    end;

    local procedure AddStatusCheck()
    begin
        TravelHeader.SetRange("No.", "Document No.");
        if TravelHeader.FindFirst then
            Error(Text004, "Document No.");
    end;

    local procedure ModifyStatusCheck()
    begin
        TravelHeader.SetRange("No.", "Document No.");
        if TravelHeader.FindFirst then
            Error(Text003, "Document No.");
    end;

    local procedure DeleteStatusCheck()
    begin
        TravelHeader.SetRange("No.", "Document No.");
        if TravelHeader.FindFirst then
            Error(Text002, "Document No.");
    end;

    local procedure GetEmployee()
    begin
        GetTravelHeader;
        //TESTFIELD(TravelHeader."Employee No.");
        if TravelHeader."Employee No." <> '' then begin
            Employee.SetRange("No.", TravelHeader."Employee No.");
            if Employee.FindFirst then;
        end;
    end;
}

