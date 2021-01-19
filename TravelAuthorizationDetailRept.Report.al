Report 50023 "Travel AuthorizationDetailRept"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/TravelAuthorizationDetailRept.rdlc';

    dataset
    {
        dataitem("Travel Request Line"; "Travel Request Line")
        {
            DataItemTableView = where("Entry Type" = filter(Accomodation | Travel | "Per Diem"), "line status" = filter(Approved));
            RequestFilterFields = "Employee No.", "Document No.", "Entry Type";
            column(ReportForNavId_1; 1)
            {
            }
            column(DocumentNo_TravelRequestLine; "Travel Request Line"."Document No.")
            {
            }
            column(EmployeeNo_TravelRequestLine; "Travel Request Line"."Employee No.")
            {
            }
            column(EmployeeName_TravelRequestLine; "Travel Request Line"."Employee Name")
            {
            }
            column(EntryType_TravelRequestLine; "Travel Request Line"."Entry Type")
            {
            }
            column(Description_TravelRequestLine; "Travel Request Line".Description)
            {
            }
            column(CurrencyCode_TravelRequestLine; "Travel Request Line"."Currency Code")
            {
            }
            column(Status_TravelRequestLine; "Travel Request Line".Status)
            {
            }
            column(TransactionDate_TravelRequestLine; "Travel Request Line"."Transaction Date")
            {
            }
            column(Department_TravelRequestLine; "Travel Request Line".Department)
            {
            }
            column(Quantity_TravelRequestLine; "Travel Request Line".Quantity)
            {
            }
            column(UnitAmount_TravelRequestLine; "Travel Request Line"."Unit Amount")
            {
            }
            column(TotalAmount_TravelRequestLine; "Travel Request Line"."Total Amount")
            {
            }
            column(TravelDate_TravelRequestLine; "Travel Request Line"."Travel Date")
            {
            }
            column(TravelFrom_TravelRequestLine; "Travel Request Line"."Travel From")
            {
            }
            column(TravelTo_TravelRequestLine; "Travel Request Line"."Travel To")
            {
            }
            column(DepartureTime_TravelRequestLine; "Travel Request Line"."Departure Time")
            {
            }
            column(ArrivalTime_TravelRequestLine; "Travel Request Line"."Arrival Time")
            {
            }
            column(PerDiemType_TravelRequestLine; "Travel Request Line"."PerDiem Type")
            {
            }
            column(BoardType_TravelRequestLine; "Travel Request Line"."Board Type")
            {
            }
            column(TitleLbl; TitleLbl)
            {
            }
            column(Name_CompanyInformation; CompanyInformation.Name)
            {
            }
            column(Address_CompanyInformation; CompanyInformation.Address)
            {
            }
            column(Address2_CompanyInformation; CompanyInformation."Address 2")
            {
            }
            column(City_CompanyInformation; CompanyInformation.City)
            {
            }
            column(County_CompanyInformation; CompanyInformation.County)
            {
            }
            column(PhoneNo_CompanyInformation; CompanyInformation."Phone No.")
            {
            }
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            column(GBranchDescription; GBranchDescription)
            {
            }
            column(GDepartmentDescription; GDepartmentDescription)
            {
            }
            column(linestatus_TravelRequestLine; "Travel Request Line"."line status")
            {
            }

            trigger OnAfterGetRecord()
            begin
                GBranchCode := '';
                GDeptCode := '';

                //TravelHeader.SETRANGE("No.","Travel Request Line"."Document No.");
                //TravelLine.SETRANGE("No.",TravelHeader."No.");
                //"Travel Request Line".SETRANGE()
                if TravelLine.FindFirst then begin

                    GBranchCode := TravelLine.Branch;
                    GDeptCode := TravelLine.Department;

                end;

                DimensionValue.SetRange(Code, GBranchCode);
                DimensionValue.SetRange("Global Dimension No.", 1);
                if DimensionValue.FindFirst then begin
                    GBranchDescription := DimensionValue.Name;
                end;


                DimensionValue.SetRange(Code, GDeptCode);
                DimensionValue.SetRange("Global Dimension No.", 2);
                if DimensionValue.FindFirst then begin
                    GDepartmentDescription := DimensionValue.Name;
                end;
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

    trigger OnInitReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        DimensionValue: Record "Dimension Value";
        GBranchDescription: Text[40];
        GDepartmentDescription: Text[40];
        GBranchCode: Code[30];
        GDeptCode: Code[30];
        Branch: Text;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Department: Text;
        TitleLbl: label 'Travel Authorization Detailed Report';
        TravelHeader: Record "Travel Request Header";
        TravelLine: Record "Travel Request Header";
}

