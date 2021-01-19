TableExtension 50000 tableextension50000 extends "Human Resources Setup"
{
    Caption = 'Human Resources Setup';
    fields
    {
        modify("Primary Key")
        {
            Caption = 'Primary Key';
        }
        modify("Employee Nos.")
        {
            Caption = 'Employee Nos.';
        }
        modify("Base Unit of Measure")
        {
            Caption = 'Base Unit of Measure';
        }

        //Unsupported feature: Code Insertion (VariableCollection) on ""Base Unit of Measure"(Field 3).OnValidate".

        //trigger (Variable: ResUnitOfMeasure)()
        //Parameters and return type have not been exported.
        //begin
        /*
        */
        //end;


        //Unsupported feature: Code Modification on ""Base Unit of Measure"(Field 3).OnValidate".

        //trigger OnValidate()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        IF "Base Unit of Measure" <> xRec."Base Unit of Measure" THEN BEGIN
          IF NOT EmployeeAbsence.ISEMPTY THEN
            ERROR(Text001,FIELDCAPTION("Base Unit of Measure"),EmployeeAbsence.TABLECAPTION);
        END;

        HumanResUnitOfMeasure.GET("Base Unit of Measure");
        HumanResUnitOfMeasure.TESTFIELD("Qty. per Unit of Measure",1);
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        #1..6
        ResUnitOfMeasure.TESTFIELD("Qty. per Unit of Measure",1);
        ResUnitOfMeasure.TESTFIELD("Related to Base Unit of Meas.");
        */
        //end;
        field(50052; "Petty Cash Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50053; "Petty Cash Account"; Code[20])
        {
            Caption = 'Petty Cash Control Acc.';
            TableRelation = "G/L Account";
        }
        field(50054; "Petty Control Account"; Code[20])
        {
            Caption = 'Petty Cash Payment Acc.';
            TableRelation = "G/L Account";
        }
        field(50060; "Travel Requisition Nos."; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(50061; "LCY Per Diem AC"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(50062; "USD Per Diem AC"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(50063; "Tax Threshold"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50064; "Ticketing Admin Email"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50065; "Enable Travel Notifications"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50066; "Accomodation Account"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(50067; "Finance Admin Email"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50068; "Procurement Admin Email"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50069; "Staff Debtors"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(50070; "Business Cards Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(50071; "Stamp Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }

    var
        ResUnitOfMeasure: Record "Resource Unit of Measure";


    //Unsupported feature: Property Modification (TextConstString) on "Text001(Variable 1002)".

    //var
    //>>>> ORIGINAL VALUE:
    //Text001 : ENU=You cannot change %1 because there are %2.;DEA=Sie können %1 nicht ändern, weil %2 vorhanden sind.;
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //Text001 : ENU=You cannot change %1 because there are %2.;
    //Variable type has not been exported.

    var
        HumanResUnitOfMeasure: Record "Human Resource Unit of Measure";
}

