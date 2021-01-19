PageExtension 50002 pageextension50002 extends "Employee Card"
{
    Caption = 'Employee Card';

    //Unsupported feature: Property Insertion (DeleteAllowed) on ""Employee Card"(Page 5200)".

    layout
    {
        modify(General)
        {
            Caption = 'General';
        }
        modify("No.")
        {
            ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
        }
        modify("First Name")
        {
            ToolTip = 'Specifies the employee''s first name.';
        }
        modify("Middle Name")
        {
            ToolTip = 'Specifies the employee''s middle name.';
        }
        modify("Last Name")
        {
            ToolTip = 'Specifies the employee''s last name.';
        }
        modify("Job Title")
        {
            ToolTip = 'Specifies the employee''s job title.';
        }
        modify(Initials)
        {
            ToolTip = 'Specifies the employee''s initials.';
        }
        modify("Search Name")
        {
            ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
        }
        modify(Gender)
        {
            ToolTip = 'Specifies the employee''s gender.';
        }
        modify("Phone No.2")
        {
            Caption = 'Company Phone No.';
            ToolTip = 'Specifies the employee''s telephone number.';
        }
        modify("Company E-Mail")
        {
            ToolTip = 'Specifies the employee''s email address at the company.';
        }
        modify("Last Date Modified")
        {
            ToolTip = 'Specifies when this record was last modified.';
        }
        modify("Privacy Blocked")
        {
            ToolTip = 'Specifies whether to limit access to data for the data subject during daily operations. This is useful, for example, when protecting data from changes while it is under privacy review.';
        }
        modify("Address & Contact")
        {
            Caption = 'Address & Contact';
        }
        modify(Address)
        {
            ToolTip = 'Specifies the employee''s address.';
        }
        modify("Address 2")
        {
            ToolTip = 'Specifies additional address information.';
        }
        modify("Post Code")
        {
            ToolTip = 'Specifies the postal code.';
        }
        modify(City)
        {
            ToolTip = 'Specifies the city of the address.';
        }
        modify("Country/Region Code")
        {
            ToolTip = 'Specifies the country/region of the address.';
        }
        modify(ShowMap)
        {
            ToolTip = 'Specifies the employee''s address on your preferred online map.';
        }
        modify("Mobile Phone No.")
        {
            Caption = 'Private Phone No.';
            ToolTip = 'Specifies the employee''s private telephone number.';
        }
        modify(Pager)
        {
            ToolTip = 'Specifies the employee''s pager number.';
        }
        modify(Extension)
        {
            ToolTip = 'Specifies the employee''s telephone extension.';
        }
        modify("Phone No.")
        {
            Caption = 'Direct Phone No.';
            ToolTip = 'Specifies the employee''s telephone number.';
        }
        modify("E-Mail")
        {
            Caption = 'Private Email';
            ToolTip = 'Specifies the employee''s private email address.';
        }
        modify("Alt. Address Code")
        {
            ToolTip = 'Specifies a code for an alternate address.';
        }
        modify("Alt. Address Start Date")
        {
            ToolTip = 'Specifies the starting date when the alternate address is valid.';
        }
        modify("Alt. Address End Date")
        {
            ToolTip = 'Specifies the last day when the alternate address is valid.';
        }
        modify(Administration)
        {
            Caption = 'Administration';
        }
        modify("Employment Date")
        {
            ToolTip = 'Specifies the date when the employee began to work for the company.';
        }
        modify(Status)
        {
            ToolTip = 'Specifies the employment status of the employee.';
        }
        modify("Inactive Date")
        {
            ToolTip = 'Specifies the date when the employee became inactive, due to disability or maternity leave, for example.';
        }
        modify("Cause of Inactivity Code")
        {
            ToolTip = 'Specifies a code for the cause of inactivity by the employee.';
        }
        modify("Termination Date")
        {
            ToolTip = 'Specifies the date when the employee was terminated, due to retirement or dismissal, for example.';
        }
        modify("Grounds for Term. Code")
        {
            ToolTip = 'Specifies a termination code for the employee who has been terminated.';
        }
        modify("Emplymt. Contract Code")
        {
            ToolTip = 'Specifies the employment contract code for the employee.';
        }
        modify("Statistics Group Code")
        {
            ToolTip = 'Specifies a statistics group code to assign to the employee for statistical purposes.';
        }
        modify("Resource No.")
        {
            ToolTip = 'Specifies a resource number for the employee.';
        }
        modify("Salespers./Purch. Code")
        {
            ToolTip = 'Specifies a salesperson or purchaser code for the employee.';
        }
        modify(Personal)
        {
            Caption = 'Personal';
        }
        modify("Birth Date")
        {
            ToolTip = 'Specifies the employee''s date of birth.';
        }
        modify("Social Security No.")
        {
            ToolTip = 'Specifies the social security number of the employee.';
        }
        modify("Union Code")
        {
            ToolTip = 'Specifies the employee''s labor union membership code.';
        }
        modify("Union Membership No.")
        {
            ToolTip = 'Specifies the employee''s labor union membership number.';
        }
        modify(Payments)
        {
            Caption = 'Payments';
        }
        modify("Employee Posting Group")
        {
            ToolTip = 'Specifies the employee''s type to link business transactions made for the employee with the appropriate account in the general ledger.';
        }
        modify("Application Method")
        {
            ToolTip = 'Specifies how to apply payments to entries for this employee.';
        }
        modify("Bank Branch No.")
        {
            ToolTip = 'Specifies a number of the bank branch.';
        }
        modify("Bank Account No.")
        {
            ToolTip = 'Specifies the number used by the bank for the bank account.';
        }
        modify(Iban)
        {
            ToolTip = 'Specifies the bank account''s international bank account number.';
        }
        modify("SWIFT Code")
        {
            Visible = false;
        }
        addafter("Last Date Modified")
        {
            field("Document Status"; "Document Status")
            {
                ApplicationArea = Basic;
                Editable = false;
            }
        }
        addafter("Salespers./Purch. Code")
        {
            field("Travel Grade"; "Travel Grade")
            {
                ApplicationArea = Basic;
            }
        }
    }
    actions
    {
        modify("E&mployee")
        {
            Caption = 'E&mployee';
        }
        modify("Co&mments")
        {
            Caption = 'Co&mments';
            ToolTip = 'View or add comments for the record.';
        }
        modify(Dimensions)
        {
            Caption = 'Dimensions';
            ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
        }
        modify("&Picture")
        {
            Caption = '&Picture';
            ToolTip = 'View or add a picture of the employee or, for example, the company''s logo.';
        }
        modify(AlternativeAddresses)
        {
            Caption = '&Alternate Addresses';
            ToolTip = 'Open the list of addresses that are registered for the employee.';
        }
        modify("&Relatives")
        {
            Caption = '&Relatives';
            ToolTip = 'Open the list of relatives that are registered for the employee.';
        }
        modify("Mi&sc. Article Information")
        {
            Caption = 'Mi&sc. Article Information';
            ToolTip = 'Open the list of miscellaneous articles that are registered for the employee.';
        }
        modify("&Confidential Information")
        {
            Caption = '&Confidential Information';
            ToolTip = 'Open the list of any confidential information that is registered for the employee.';
        }
        modify("Q&ualifications")
        {
            Caption = 'Q&ualifications';
            ToolTip = 'Open the list of qualifications that are registered for the employee.';
        }
        modify("A&bsences")
        {
            Caption = 'A&bsences';
            ToolTip = 'View absence information for the employee.';
        }
        modify("Absences by Ca&tegories")
        {
            Caption = 'Absences by Ca&tegories';
            ToolTip = 'View categorized absence information for the employee.';
        }
        modify("Misc. Articles &Overview")
        {
            Caption = 'Misc. Articles &Overview';
            ToolTip = 'View miscellaneous articles that are registered for the employee.';
        }
        modify("Co&nfidential Info. Overview")
        {
            Caption = 'Co&nfidential Info. Overview';
            ToolTip = 'View confidential information that is registered for the employee.';
        }
        modify("Ledger E&ntries")
        {
            Caption = 'Ledger E&ntries';
            ToolTip = 'View the history of transactions that have been posted for the selected record.';
        }
        addafter("E&mployee")
        {
            group(Approval)
            {
                Caption = 'Approval';
                action("<Action111>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        if "Document Status" = "document status"::"Pending Approval" then
                            Error('Note: Employee has already been sent for Approval');

                        VarVariant := Rec;
                        /* if CustomApprovals.CheckApprovalsWorkflowEnabled(VarVariant) then
                            CustomApprovals.OnSendDocForApproval(VarVariant); */

                        Message('Document Successfully sent for approval');
                    end;
                }
                action("<Action112>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Request';
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin

                        VarVariant := Rec;
                        //CustomApprovals.OnCancelDocApprovalRequest(VarVariant);
                    end;
                }
                action("<Action113>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approval Entry';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Approval Entries";
                    RunPageLink = "Document No." = field("No.");
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reopen';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                    //ApprovalsMgmt: Codeunit UnknownCodeunit51105;
                    begin


                        if Confirm(Text010) then begin
                            "Document Status" := "document status"::Open;
                            Modify;
                        end;
                    end;
                }
            }
        }
    }


    //Unsupported feature: Property Modification (TextConstString) on "ShowMapLbl(Variable 1000)".

    //var
    //>>>> ORIGINAL VALUE:
    //ShowMapLbl : ENU=Show on Map;DEA=Auf Karte anzeigen;
    //Variable type has not been exported.
    //>>>> MODIFIED VALUE:
    //ShowMapLbl : ENU=Show on Map;
    //Variable type has not been exported.

    var
        VarVariant: Variant;
        //CustomApprovals: Codeunit UnknownCodeunit50011;
        Text010: label 'Do you want to Reopen the Employee Card?';


    //Unsupported feature: Code Insertion on "OnInsertRecord".

    //trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    //begin
    /*
    TESTFIELD("Document Status","Document Status"::Open);
    */
    //end;


    //Unsupported feature: Code Insertion on "OnModifyRecord".

    //trigger OnModifyRecord(): Boolean
    //begin
    /*
    TESTFIELD("Document Status","Document Status"::Open);
    */
    //end;
}

