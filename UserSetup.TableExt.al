TableExtension 50001 tableextension50001 extends "User Setup"
{
    Caption = 'User Setup';
    fields
    {
        modify("User ID")
        {
            Caption = 'User ID';
        }
        modify("Allow Posting From")
        {
            Caption = 'Allow Posting From';
        }
        modify("Allow Posting To")
        {
            Caption = 'Allow Posting To';
        }
        modify("Register Time")
        {
            Caption = 'Register Time';
        }
        modify("Salespers./Purch. Code")
        {

            //Unsupported feature: Property Modification (Data type) on ""Salespers./Purch. Code"(Field 10)".

            TableRelation = "Salesperson/Purchaser".Code;
            Caption = 'Salespers./Purch. Code';
        }
        modify("Approver ID")
        {
            Caption = 'Approver ID';
        }
        modify("Sales Amount Approval Limit")
        {
            Caption = 'Sales Amount Approval Limit';
        }
        modify("Purchase Amount Approval Limit")
        {
            Caption = 'Purchase Amount Approval Limit';
        }
        modify("Unlimited Sales Approval")
        {
            Caption = 'Unlimited Sales Approval';
        }
        modify("Unlimited Purchase Approval")
        {
            Caption = 'Unlimited Purchase Approval';
        }
        modify(Substitute)
        {
            Caption = 'Substitute';
        }
        modify("E-Mail")
        {
            Caption = 'E-Mail';
        }
        modify("Request Amount Approval Limit")
        {
            Caption = 'Request Amount Approval Limit';
        }
        modify("Unlimited Request Approval")
        {
            Caption = 'Unlimited Request Approval';
        }
        modify("Approval Administrator")
        {
            Caption = 'Approval Administrator';
        }
        modify("License Type")
        {
            Caption = 'License Type';
            OptionCaption = 'Full User,Limited User,Device Only User,Windows Group,External User';
        }
        modify("Time Sheet Admin.")
        {
            Caption = 'Time Sheet Admin.';
        }
        modify("Allow FA Posting From")
        {
            Caption = 'Allow FA Posting From';
        }
        modify("Allow FA Posting To")
        {
            Caption = 'Allow FA Posting To';
        }
        modify("Sales Resp. Ctr. Filter")
        {
            Caption = 'Sales Resp. Ctr. Filter';
        }
        modify("Purchase Resp. Ctr. Filter")
        {
            Caption = 'Purchase Resp. Ctr. Filter';
        }
        modify("Service Resp. Ctr. Filter")
        {
            Caption = 'Service Resp. Ctr. Filter';
        }

        //Unsupported feature: Property Deletion (DataClassification) on ""User ID"(Field 1)".


        //Unsupported feature: Deletion on ""Allow Posting From"(Field 2).OnValidate".


        //Unsupported feature: Deletion on ""Allow Posting To"(Field 3).OnValidate".


        //Unsupported feature: Code Modification on ""Salespers./Purch. Code"(Field 10).OnValidate".

        //trigger /Purch()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        IF "Salespers./Purch. Code" <> '' THEN BEGIN
          ValidateSalesPersonPurchOnUserSetup(Rec);
          UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
          UserSetup.SETRANGE("Salespers./Purch. Code","Salespers./Purch. Code");
          IF UserSetup.FINDFIRST THEN
            ERROR(Text001,"Salespers./Purch. Code",UserSetup."User ID");
          UpdateSalesPerson;
        END;
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        IF "Salespers./Purch. Code" <> '' THEN BEGIN
        #3..6
        END;
        */
        //end;

        //Unsupported feature: Property Deletion (DataClassification) on ""Approver ID"(Field 11)".


        //Unsupported feature: Property Deletion (DataClassification) on "Substitute(Field 16)".


        //Unsupported feature: Deletion on ""E-Mail"(Field 17).OnValidate".

        field(50000; "Change Line Discount"; Boolean)
        {
        }
        field(50001; "Edit Printed Receipt/PCV/CRV"; Boolean)
        {
        }
        field(50002; "Delete Stock Take Sheet"; Boolean)
        {
        }
        field(50003; "Salesperson Code"; Code[10])
        {
            Description = 'Sales Person Code for this User Login, Controls Access to Prospects';
            TableRelation = "Salesperson/Purchaser";
        }
        field(50004; "Access All Prospects"; Boolean)
        {
            Description = 'Gives access to all prospect cards if activated';
        }
        field(50005; "Edit Branch Order"; Boolean)
        {
            Description = 'Allows  User to edit the Branch Order after BOC is printed';
        }
        field(50006; "Override Credit Limit"; Boolean)
        {
        }
        field(50007; "Access Credit HP Accounts"; Boolean)
        {
            Description = 'Allows the user to access ledger entries & account balance in a HP customer account with credit balance';
        }
        field(50008; Cashier; Boolean)
        {
        }
        field(50009; "Access  Post-dated Cheques"; Boolean)
        {
            Description = 'NAS SR6';
        }
        field(50010; "Edit Location"; Boolean)
        {
            Description = '//NAS GR1 identify users allowed to edit location code on document headers';
        }
        field(50011; "Void Cheques"; Boolean)
        {
        }
        field(50012; "Print Cheques"; Boolean)
        {
        }
        field(50013; "Re-Print Cheques"; Boolean)
        {
        }
        field(50014; "Edit Budget Overrun"; Boolean)
        {
        }
        field(50015; "Re-Print Posted Sales Invoices"; Boolean)
        {
            Description = 'NAS Customization by SNG 230311';
        }
        field(50016; "Location User"; Boolean)
        {
            Description = '//NAS GR1 identify users required to use location login';
        }
        field(50017; "Edit Purch. Quote/LPO Validity"; Boolean)
        {
        }
        field(50018; "Edit Sales Quote Validity"; Boolean)
        {
        }
        field(50019; "Edit Service Quote Validity"; Boolean)
        {
        }
        field(50020; "Edit Store/Purch Req. Validity"; Boolean)
        {
        }
        field(50021; "Allow Multiple Acq. Per Asset"; Boolean)
        {
            Description = 'ICS FAS04';
        }
        field(50022; "Preview Non-Approved LPOs"; Boolean)
        {
        }
        field(50023; "Restrict Sales Line Desc Edit"; Boolean)
        {
        }
        field(50024; "Re-Print Warranty Invoice"; Boolean)
        {
        }
        field(50025; "Verify Sales Orders"; Boolean)
        {
        }
        field(50026; "Input Salesperson Targets"; Boolean)
        {
        }
        field(50151; "Give Access to Payroll"; Code[10])
        {
        }
        field(50152; "Payroll Batch"; Code[10])
        {
            TableRelation = "Gen. Journal Batch" where("Journal Template Name" = filter('GENERAL'));
        }
        field(50153; "Full Name"; Text[50])
        {
        }
        field(50154; "Department Code"; Code[20])
        {
            Caption = 'Department Code';
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('DEPARTMENT'));

            trigger OnValidate()
            begin
                //ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
            end;
        }
        field(50155; "Employee No."; Code[20])
        {
            TableRelation = Employee;
        }
        field(50156; "Re-Export EFT"; Boolean)
        {
        }
        field(50157; "EFT User"; Boolean)
        {
        }
        field(50158; "View Item Cost"; Boolean)
        {
        }
        field(50200; "HR Administrator"; Boolean)
        {
        }
        field(50201; "Petty Cash Administrator"; Boolean)
        {
        }
        field(50202; "Singe Level Petty Cash Approva"; Boolean)
        {
        }
        field(50203; "Allow Journal Reversals"; Boolean)
        {
        }
        field(50204; "Run Customer Blocking Batch"; Boolean)
        {
        }
        field(50205; "RReal Petty Cash User"; Boolean)
        {
        }
        field(50206; "Vendor EFT Details Approver"; Boolean)
        {
        }
        field(50207; Branch; Code[20])
        {
            TableRelation = "Dimension Value".Code where("Dimension Code" = filter('BRANCH'));
        }
        field(50208; Location; Code[20])
        {
            TableRelation = Location;
        }
        field(50209; "Head of Department"; Boolean)
        {
        }
        field(50210; "Head of Finance"; Boolean)
        {
        }
        field(50211; "ICT Approver"; Boolean)
        {
        }
        field(50212; "Facility Approver"; Boolean)
        {
        }
        field(50213; "Finance Approver"; Boolean)
        {
        }
        field(50214; "HR Manager"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50215; "Stores Officer"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50216; "MD Approver"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50217; HOD; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";
        }
        field(50218; "Approval Delegated"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50219; "Delegation Expiry"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50220; "Procurement Manager"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50221; "Overall HOD Branch"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50222; "CST HOD"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50223; "Dept HRBP"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";
        }
        field(50224; "PO Locking Permission"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50225; "Create Contract"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50226; "Can Reassign Period"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Branch)
        {
        }
        key(Key2; "Facility Approver")
        {
        }
        key(Key3; "ICT Approver")
        {
        }
        key(Key4; "Finance Approver")
        {
        }
        key(Key5; "HR Administrator")
        {
        }
        key(Key6; "Department Code")
        {
        }
        key(Key7; "Procurement Manager")
        {
        }
    }

    //Unsupported feature: Property Deletion (Attributes) on "CreateApprovalUserSetup(PROCEDURE 3)".


    //Unsupported feature: Property Deletion (Attributes) on "GetDefaultSalesAmountApprovalLimit(PROCEDURE 1)".


    //Unsupported feature: Property Deletion (Attributes) on "GetDefaultPurchaseAmountApprovalLimit(PROCEDURE 2)".


    //Unsupported feature: Property Deletion (Attributes) on "HideExternalUsers(PROCEDURE 5)".



    //Unsupported feature: Property Modification (TextConstString) on "Text001(Variable 1000)".

    //var
    //>>>> ORIGINAL VALUE:
    //Text001 : ENU=The %1 Salesperson/Purchaser code is already assigned to another User ID %2.;DEA=Der Verkäufer-/Einkäufercode '%1' ist bereits einer anderen Benutzer-ID '%2' zugewiesen.;
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //Text001 : ENU=The %1 Salesperson/Purchaser code is already assigned to another User ID %2.;
    //Variable type has not been exported.


    //Unsupported feature: Property Modification (TextConstString) on "Text003(Variable 1002)".

    //var
    //>>>> ORIGINAL VALUE:
    //Text003 : ENU="You cannot have both a %1 and %2. ";DEA="%1 und %2 können nicht zugleich vorhanden sein. ";
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //Text003 : ENU="You cannot have both a %1 and %2. ";
    //Variable type has not been exported.


    //Unsupported feature: Property Modification (TextConstString) on "Text005(Variable 1004)".

    //var
    //>>>> ORIGINAL VALUE:
    //Text005 : ENU=You cannot have approval limits less than zero.;DEA=Die Genehmigungsgrenzwerte können nicht kleiner als Null sein.;
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //Text005 : ENU=You cannot have approval limits less than zero.;
    //Variable type has not been exported.
}

