Page 50046 "Stamps HOD Approver"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Travel Request Header";
    SourceTableView = where("Approval Status"=const("Pending Approval"),
                            Type=filter(Stamp));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(No;"No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Department;Department)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(EmployeeNo;"Employee No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(EmployeeName;"Employee Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(RaisedBy;"Raised By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(ApprovalRemarks;"Approval Remarks")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Approvals)
            {
                Caption = '&Approvals';
                action(ReviewDocument)
                {
                    ApplicationArea = Basic;
                    Caption = '&Review Document';
                    Image = ReviewWorksheet;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "Stamps Request";
                    RunPageLink = "No."=field("No.");
                }
                action(Approve)
                {
                    ApplicationArea = Basic;
                    Caption = '&Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CRLF: Text[30];
                        LUser: Record "User Setup";
                        LUser2: Record "User Setup";
                        LHumanResSetup: Record "Human Resources Setup";
                        LEmployee: Record Employee;
                        LSMTPMailSetup: Record "SMTP Mail Setup";
                        LSMTPMail: Codeunit "SMTP Mail";
                    begin
                        //TravelMgmt.ApproveBusinessCardApproval(Rec);
                        TravelMgmt.HODStampApproval(Rec);
                    end;
                }
                action(Disapprove)
                {
                    ApplicationArea = Basic;
                    Caption = '&Disapprove';
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CRLF: Text[30];
                        LUser: Record "User Setup";
                        LUser2: Record "User Setup";
                        LHumanResSetup: Record "Human Resources Setup";
                        LEmployee: Record Employee;
                        LSMTPMailSetup: Record "SMTP Mail Setup";
                        LSMTPMail: Codeunit "SMTP Mail";
                    begin
                        TestField("Approval Remarks");
                        //TravelMgmt.DisapproveBusinessCardApproval(Rec);
                        TravelMgmt.HODDisapproveStampApproval(Rec);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetFilter("Approval Status",'%1',"approval status"::"Pending HOD");
        SetRange("Proc Manager", UserId);
        FilterGroup(0);
    end;

    var
        TravelMgmt: Codeunit "Travel Management";
}

