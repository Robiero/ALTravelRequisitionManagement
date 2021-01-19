TableExtension 50002 tableextension50002 extends Employee
{
    Caption = 'Employee';
    fields
    {
        modify("No.")
        {
            Caption = 'No.';
        }
        modify("First Name")
        {
            Caption = 'First Name';
        }
        modify("Middle Name")
        {
            Caption = 'Middle Name';
        }
        modify("Last Name")
        {
            Caption = 'Last Name';
        }
        modify(Initials)
        {
            Caption = 'Initials';
        }
        modify("Job Title")
        {
            Caption = 'Job Title';
        }
        modify("Search Name")
        {
            Caption = 'Search Name';
        }
        modify(Address)
        {
            Caption = 'Address';
        }
        modify("Address 2")
        {
            Caption = 'Address 2';
        }
        modify(City)
        {
            Caption = 'City';
        }
        modify("Post Code")
        {
            Caption = 'Post Code';
        }
        modify(County)
        {
            Caption = 'County';
        }
        modify("Phone No.")
        {
            Caption = 'Phone No.';
        }
        modify("Mobile Phone No.")
        {
            Caption = 'Mobile Phone No.';
        }
        modify("E-Mail")
        {
            Caption = 'Email';
        }
        modify("Alt. Address Code")
        {
            Caption = 'Alt. Address Code';
        }
        modify("Alt. Address Start Date")
        {
            Caption = 'Alt. Address Start Date';
        }
        modify("Alt. Address End Date")
        {
            Caption = 'Alt. Address End Date';
        }
        /* modify(Image)
        {
            Caption = 'Image';
        } */
        modify("Birth Date")
        {
            Caption = 'Birth Date';
        }
        modify("Social Security No.")
        {
            Caption = 'Social Security No.';
        }
        modify("Union Code")
        {
            Caption = 'Union Code';
        }
        modify("Union Membership No.")
        {
            Caption = 'Union Membership No.';
        }
        modify(Gender)
        {
            Caption = 'Gender';
            OptionCaption = ' ,Female,Male';
        }
        modify("Country/Region Code")
        {
            Caption = 'Country/Region Code';
        }
        modify("Manager No.")
        {
            Caption = 'Manager No.';
        }
        modify("Emplymt. Contract Code")
        {
            Caption = 'Emplymt. Contract Code';
        }
        modify("Statistics Group Code")
        {
            Caption = 'Statistics Group Code';
        }
        modify("Employment Date")
        {
            Caption = 'Employment Date';
        }
        modify(Status)
        {
            Caption = 'Status';
            OptionCaption = 'Active,Inactive,Terminated';
        }
        modify("Inactive Date")
        {
            Caption = 'Inactive Date';
        }
        modify("Cause of Inactivity Code")
        {
            Caption = 'Cause of Inactivity Code';
        }
        modify("Termination Date")
        {
            Caption = 'Termination Date';
        }
        modify("Grounds for Term. Code")
        {
            Caption = 'Grounds for Term. Code';
        }
        modify("Global Dimension 1 Code")
        {
            Caption = 'Global Dimension 1 Code';
        }
        modify("Global Dimension 2 Code")
        {
            Caption = 'Global Dimension 2 Code';
        }
        modify("Resource No.")
        {
            Caption = 'Resource No.';
        }
        modify(Comment)
        {
            Caption = 'Comment';
        }
        modify("Last Date Modified")
        {
            Caption = 'Last Date Modified';
        }
        modify("Date Filter")
        {
            Caption = 'Date Filter';
        }
        modify("Global Dimension 1 Filter")
        {
            Caption = 'Global Dimension 1 Filter';
        }
        modify("Global Dimension 2 Filter")
        {
            Caption = 'Global Dimension 2 Filter';
        }
        modify("Cause of Absence Filter")
        {
            Caption = 'Cause of Absence Filter';
        }
        modify("Total Absence (Base)")
        {
            Caption = 'Total Absence (Base)';
        }
        modify(Extension)
        {
            Caption = 'Extension';
        }
        modify("Employee No. Filter")
        {
            Caption = 'Employee No. Filter';
        }
        modify(Pager)
        {
            Caption = 'Pager';
        }
        modify("Fax No.")
        {
            Caption = 'Fax No.';
        }
        modify("Company E-Mail")
        {
            Caption = 'Company Email';
        }
        modify(Title)
        {
            Caption = 'Title';
        }
        modify("Salespers./Purch. Code")
        {
            Caption = 'Salespers./Purch. Code';
        }
        modify("No. Series")
        {
            Caption = 'No. Series';
        }
        modify("Last Modified Date Time")
        {
            Caption = 'Last Modified Date Time';
        }
        modify("Employee Posting Group")
        {
            Caption = 'Employee Posting Group';
        }
        modify("Bank Branch No.")
        {
            Caption = 'Bank Branch No.';
        }
        modify("Bank Account No.")
        {
            Caption = 'Bank Account No.';
        }
        modify(Iban)
        {
            Caption = 'IBAN';
        }
        modify(Balance)
        {
            Caption = 'Balance';
        }
        modify("SWIFT Code")
        {
            Caption = 'SWIFT Code';
        }
        modify("Application Method")
        {
            Caption = 'Application Method';
            OptionCaption = 'Manual,Apply to Oldest';
        }
        /* modify(Image)
        {
            Caption = 'Image';
        } */
        modify("Privacy Blocked")
        {
            Caption = 'Privacy Blocked';
        }
        modify("Cost Center Code")
        {
            Caption = 'Cost Center Code';
        }
        modify("Cost Object Code")
        {
            Caption = 'Cost Object Code';
        }
        modify(Image)
        {
            Caption = 'image';
        }

        //Unsupported feature: Deletion on "City(Field 10).OnLookup".


        //Unsupported feature: Deletion on ""Post Code"(Field 11).OnLookup".


        //Unsupported feature: Deletion on ""Country/Region Code"(Field 25).OnValidate".

        field(50060; "Travel Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Travel Grade" where("Currency Code" = const(''));
        }
        field(50061; "Document Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Open,Pending Approval,Cancelled,Approved';
            OptionMembers = Open,"Pending Approval",Cancelled,Approved;
        }
    }


    //Unsupported feature: Code Modification on "OnInsert".

    //trigger OnInsert()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    "Last Modified Date Time" := CURRENTDATETIME;
    IF "No." = '' THEN BEGIN
      HumanResSetup.GET;
    #4..8
      DATABASE::Employee,"No.",
      "Global Dimension 1 Code","Global Dimension 2 Code");
    UpdateSearchName;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*

    #1..11
    */
    //end;


    //Unsupported feature: Code Modification on "OnModify".

    //trigger OnModify()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    "Last Modified Date Time" := CURRENTDATETIME;
    "Last Date Modified" := TODAY;
    IF Res.READPERMISSION THEN
      EmployeeResUpdate.HumanResToRes(xRec,Rec);
    IF SalespersonPurchaser.READPERMISSION THEN
      EmployeeSalespersonUpdate.HumanResToSalesPerson(xRec,Rec);
    UpdateSearchName;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*

    #1..7
    */
    //end;


    //Unsupported feature: Property Modification (TextConstString) on "Text000(Variable 1016)".

    //var
    //>>>> ORIGINAL VALUE:
    //Text000 : ENU=Before you can use Online Map, you must fill in the Online Map Setup window.\See Setting Up Online Map in Help.;DEA=Bevor Sie Online Map verwenden können, müssen Sie die Felder des Fensters 'Online Map-Einrichtung' ausfüllen.\Informationen hierzu finden Sie in der Hilfe zum Einrichten von Online Map.;
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //Text000 : ENU=Before you can use Online Map, you must fill in the Online Map Setup window.\See Setting Up Online Map in Help.;
    //Variable type has not been exported.


    //Unsupported feature: Property Modification (TextConstString) on "BlockedEmplForJnrlErr(Variable 1001)".

    //var
    //>>>> ORIGINAL VALUE:
    //BlockedEmplForJnrlErr : @@@="%1 = employee no.";ENU=You cannot create this document because employee %1 is blocked due to privacy.;DEA=Sie können diesen Beleg nicht erstellen, weil die Ressource %1 aus Datenschutzgründen gesperrt ist.;
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //BlockedEmplForJnrlErr : @@@="%1 = employee no.";ENU=You cannot create this document because employee %1 is blocked due to privacy.;
    //Variable type has not been exported.


    //Unsupported feature: Property Modification (TextConstString) on "BlockedEmplForJnrlPostingErr(Variable 1017)".

    //var
    //>>>> ORIGINAL VALUE:
    //BlockedEmplForJnrlPostingErr : @@@="%1 = employee no.";ENU=You cannot post this document because employee %1 is blocked due to privacy.;DEA=Sie können diesen Beleg nicht buchen, weil der Mitarbeiter %1 aus Datenschutzgründen gesperrt ist.;
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //BlockedEmplForJnrlPostingErr : @@@="%1 = employee no.";ENU=You cannot post this document because employee %1 is blocked due to privacy.;
    //Variable type has not been exported.
}

