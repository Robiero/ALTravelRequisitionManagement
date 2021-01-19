Report 50022 "Approved Business Cards Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/ApprovedBusinessCardsReport.rdlc';

    dataset
    {
        dataitem("Travel Request Header";"Travel Request Header")
        {
            DataItemTableView = where(Type=filter("Business Card"),"Approval Status"=filter(Approved));
            column(ReportForNavId_1; 1)
            {
            }
            column(NoSeries_TravelRequestHeader;"Travel Request Header"."No. Series")
            {
            }
            column(Branch_TravelRequestHeader;"Travel Request Header".Branch)
            {
            }
            column(Title_TravelRequestHeader;"Travel Request Header".Title)
            {
            }
            column(PhysicalLocation_TravelRequestHeader;"Travel Request Header"."Physical Location")
            {
            }
            column(Address_TravelRequestHeader;"Travel Request Header".Address)
            {
            }
            column(CellNumber_TravelRequestHeader;"Travel Request Header"."Cell Number")
            {
            }
            column(TelephoneNumber_TravelRequestHeader;"Travel Request Header"."Telephone Number")
            {
            }
            column(DirectTelephone_TravelRequestHeader;"Travel Request Header"."Direct Telephone")
            {
            }
            column(FaxNumber_TravelRequestHeader;"Travel Request Header"."Fax Number")
            {
            }
            column(QtyRequested_TravelRequestHeader;"Travel Request Header"."Qty Requested")
            {
            }
            column(No_TravelRequestHeader;"Travel Request Header"."No.")
            {
            }
            column(Department_TravelRequestHeader;"Travel Request Header".Department)
            {
            }
            column(EmployeeNo_TravelRequestHeader;"Travel Request Header"."Employee No.")
            {
            }
            column(EmployeeName_TravelRequestHeader;"Travel Request Header"."Employee Name")
            {
            }
            column(ApprovalStatus_TravelRequestHeader;"Travel Request Header"."Approval Status")
            {
            }
            column(EmailAddress_TravelRequestHeader;"Travel Request Header"."Email Address")
            {
            }
            column(Name_TravelRequestHeader;"Travel Request Header".Name)
            {
            }
            column(TitleLbl;TitleLbl)
            {
            }
            column(Name_CompanyInformation;CompanyInformation.Name)
            {
            }
            column(Address_CompanyInformation;CompanyInformation.Address)
            {
            }
            column(Address2_CompanyInformation;CompanyInformation."Address 2")
            {
            }
            column(City_CompanyInformation;CompanyInformation.City)
            {
            }
            column(County_CompanyInformation;CompanyInformation.County)
            {
            }
            column(PhoneNo_CompanyInformation;CompanyInformation."Phone No.")
            {
            }
            column(Picture_CompanyInformation;CompanyInformation.Picture)
            {
            }
            column(GDeptDescription;Department)
            {
            }
            column(GBranchDescription;Branch)
            {
            }

            trigger OnAfterGetRecord()
            begin

                GeneralLedgerSetup.Get;
                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 1 Code");
                DimensionValue.SetRange(Code,"Travel Request Header".Branch);
                if DimensionValue.FindFirst then
                  Branch:= DimensionValue.Name;

                GeneralLedgerSetup.Get;
                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 1 Code");
                DimensionValue.SetRange(Code,"Travel Request Header".Branch);
                if DimensionValue.FindFirst then
                  GeneralLedgerSetup.Get;
                DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 2 Code");
                DimensionValue.SetRange(Code,"Travel Request Header".Department);
                if DimensionValue.FindFirst then
                  Department:= DimensionValue.Name;
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
        TitleLbl: label 'Approved Business Cards Report';
        DimensionValue: Record "Dimension Value";
        GBranchDescription: Text[40];
        GDepartmentDescription: Text[40];
        GBranchCode: Code[30];
        GDeptCode: Code[30];
        Branch: Text;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Department: Text;
}

