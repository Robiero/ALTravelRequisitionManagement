Report 51109 "Travel Request"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/TravelRequest.rdlc';

    dataset
    {
        dataitem("Travel Request Header"; "Travel Request Header")
        {
            column(ReportForNavId_1; 1)
            {
            }
            column(No_TravelRequestHeader; "Travel Request Header"."No.")
            {
            }
            column(Department_TravelRequestHeader; "Travel Request Header".Department)
            {
            }
            column(EmployeeNo_TravelRequestHeader; "Travel Request Header"."Employee No.")
            {
            }
            column(EmployeeName_TravelRequestHeader; "Travel Request Header"."Employee Name")
            {
            }
            column(RaisedDate_TravelRequestHeader; "Travel Request Header"."Raised Date")
            {
            }
            column(RaisedBy_TravelRequestHeader; "Travel Request Header"."Raised By")
            {
            }
            column(ApprovalStatus_TravelRequestHeader; "Travel Request Header"."Approval Status")
            {
            }
            column(NoSeries_TravelRequestHeader; "Travel Request Header"."No. Series")
            {
            }
            column(CurrencyCode_TravelRequestHeader; "Travel Request Header"."Currency Code")
            {
            }
            column(Location_TravelRequestHeader; "Travel Request Header".Location)
            {
            }
            column(HRApprovalStatus_TravelRequestHeader; "Travel Request Header"."HR Approval Status")
            {
            }
            column(ApprovalBy_TravelRequestHeader; "Travel Request Header"."Approval By")
            {
            }
            column(EmployeeGrade_TravelRequestHeader; "Travel Request Header"."Employee Grade")
            {
            }
            column(TravelFromDate_TravelRequestHeader; "Travel Request Header"."Travel From Date")
            {
            }
            column(TravelToDate_TravelRequestHeader; "Travel Request Header"."Travel To Date")
            {
            }
            column(NoofDays_TravelRequestHeader; "Travel Request Header"."No. of Days")
            {
            }
            column(TravelPurpose_TravelRequestHeader; "Travel Request Header"."Travel Purpose")
            {
            }
            column(TravelFrom_TravelRequestHeader; "Travel Request Header"."Travel From")
            {
            }
            column(TravelTo_TravelRequestHeader; "Travel Request Header"."Travel To")
            {
            }
            column(AccomodationVendorNo_TravelRequestHeader; "Travel Request Header"."Accomodation Vendor No.")
            {
            }
            column(AccomodationVendorName_TravelRequestHeader; "Travel Request Header"."Accomodation Vendor Name")
            {
            }
            column(TravelMode_TravelRequestHeader; "Travel Request Header"."Travel Mode")
            {
            }
            column(Amount_TravelRequestHeader; "Travel Request Header".Amount)
            {
            }
            column(AccomodationType_TravelRequestHeader; "Travel Request Header"."Accomodation Type")
            {
            }
            column(HRApprovalBy_TravelRequestHeader; "Travel Request Header"."HR Approval By")
            {
            }
            column(Approver_TravelRequestHeader; "Travel Request Header".Approver)
            {
            }
            column(HRManagerApprover_TravelRequestHeader; "Travel Request Header"."HR Manager Approver")
            {
            }
            column(ApprovalDate_TravelRequestHeader; "Travel Request Header"."Approval Date")
            {
            }
            column(HRApprovalDate_TravelRequestHeader; "Travel Request Header"."HR Approval Date")
            {
            }
            column(ApprovalRemarks_TravelRequestHeader; "Travel Request Header"."Approval Remarks")
            {
            }
            column(HRBPApprover_TravelRequestHeader; "Travel Request Header"."HRBP Approver")
            {
            }
            column(HRApprovalRemarks_TravelRequestHeader; "Travel Request Header"."HR Approval Remarks")
            {
            }
            column(Branch_TravelRequestHeader; "Travel Request Header".Branch)
            {
            }
            column(TravelVendorNo_TravelRequestHeader; "Travel Request Header"."Travel Vendor No.")
            {
            }
            column(TravelVendorName_TravelRequestHeader; "Travel Request Header"."Travel Vendor Name")
            {
            }
            column(Title_TravelRequestHeader; "Travel Request Header".Title)
            {
            }
            column(PhysicalLocation_TravelRequestHeader; "Travel Request Header"."Physical Location")
            {
            }
            column(Address_TravelRequestHeader; "Travel Request Header".Address)
            {
            }
            column(CellNumber_TravelRequestHeader; "Travel Request Header"."Cell Number")
            {
            }
            column(TelephoneNumber_TravelRequestHeader; "Travel Request Header"."Telephone Number")
            {
            }
            column(DirectTelephone_TravelRequestHeader; "Travel Request Header"."Direct Telephone")
            {
            }
            column(FaxNumber_TravelRequestHeader; "Travel Request Header"."Fax Number")
            {
            }
            column(QtyRequested_TravelRequestHeader; "Travel Request Header"."Qty Requested")
            {
            }
            column(Type_TravelRequestHeader; "Travel Request Header".Type)
            {
            }
            column(LineAppDate_TravelRequestHeader; "Travel Request Header"."Line App Date")
            {
            }
            column(HRBPAppDate_TravelRequestHeader; "Travel Request Header"."HRBP App Date")
            {
            }
            column(HRMgrAppDate_TravelRequestHeader; "Travel Request Header"."HR Mgr App Date")
            {
            }
            column(SubmitDate_TravelRequestHeader; "Travel Request Header"."Submit Date")
            {
            }
            column(HRSubmitDate_TravelRequestHeader; "Travel Request Header"."HR Submit Date")
            {
            }
            column(ProcManager_TravelRequestHeader; "Travel Request Header"."Proc Manager")
            {
            }
            column(StampType_TravelRequestHeader; "Travel Request Header"."Stamp Type")
            {
            }
            column(Justification_TravelRequestHeader; "Travel Request Header".Justification)
            {
            }
            column(RequestedBy; RequestedBy)
            {
            }
            column(LineApprover; LineApprover)
            {
            }
            column(Branch; Branch)
            {
            }
            column(Department; Department)
            {
            }
            column(HODProc; HODProc)
            {
            }
            column(HRManagerApprover; HRManagerApprover)
            {
            }
            dataitem("Travel Request Line"; "Travel Request Line")
            {
                column(ReportForNavId_55; 55)
                {
                }
                column(BoardType_TravelRequestLine; "Travel Request Line"."Board Type")
                {
                }
                column(BoardType; BoardType)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //travelheader.GET;
                    travelline.SetRange("Document No.", "Travel Request Header"."No.");
                    travelline.SetRange("Entry Type", travelline."entry type"::Accomodation);
                    if travelline.FindFirst then
                        BoardType := Format(travelline."Board Type");
                end;
            }

            trigger OnAfterGetRecord()
            begin

                UserSetup.Get("Travel Request Header"."Raised By");
                UserSetup.SetRange("User ID", "Travel Request Header"."Raised By");
                if UserSetup.FindFirst then begin
                    RequestedBy := UserSetup."Full Name";
                end;
                UserSetup.Get("Travel Request Header".Approver);
                UserSetup.SetRange("User ID", "Travel Request Header".Approver);
                if UserSetup.FindFirst then begin
                    LineApprover := UserSetup."Full Name";

                    UserSetup.Get("Travel Request Header"."HR Manager Approver");
                    UserSetup.SetRange("User ID", "Travel Request Header"."HR Manager Approver");
                    if UserSetup.FindFirst then begin
                        HRManagerApprover := UserSetup."Full Name";
                    end;

                end;
                //proc mgr fro stamps
                // UserSetup.GET("Travel Request Header"."Proc Manager");
                // UserSetup.SETRANGE("User ID","Travel Request Header"."Proc Manager");
                // IF UserSetup.FINDFIRST THEN BEGIN
                //  HODProc:= UserSetup."Full Name"
                //  END;

                GeneralLedgerSetup.Get;
                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 1 Code");
                DimensionValue.SetRange(Code, "Travel Request Header".Branch);
                if DimensionValue.FindFirst then
                    Branch := DimensionValue.Name;

                GeneralLedgerSetup.Get;
                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 1 Code");
                DimensionValue.SetRange(Code, "Travel Request Header".Branch);
                if DimensionValue.FindFirst then
                    GeneralLedgerSetup.Get;
                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 2 Code");
                DimensionValue.SetRange(Code, "Travel Request Header".Department);
                if DimensionValue.FindFirst then
                    Department := DimensionValue.Name;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        UserSetup: Record "User Setup";
        RequestedBy: Text;
        LineApprover: Text;
        HODFinance: Text;
        DimensionValue: Record "Dimension Value";
        Branch: Text;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Department: Text;
        HODProc: Text;
        HRManagerApprover: Text;
        travelheader: Record "Travel Request Header";
        travelline: Record "Travel Request Line";
        BoardType: Text;
}

