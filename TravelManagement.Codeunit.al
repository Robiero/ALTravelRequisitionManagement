Codeunit 50010 "Travel Management"
{
    // PRHODFinanceApproval

    TableNo = "Travel Request Header";

    trigger OnRun()
    begin
        TravelHeader.Init;
        TravelHeader.Copy(Rec);
        with TravelHeader do begin
            PostTravel(TravelHeader);
            //PrintVoucher(TravelHeader);
            Window.Open(
            '#1############################\\' +
            Text000);
            Window.Update(1, StrSubstNo('Travel requisition %1', "No."));

            Message('Travel disbursment and notification successful');
        end;
    end;

    var
        TravelHeader: Record "Travel Request Header";
        TravelLine: Record "Travel Request Line";
        Window: Dialog;
        UserSetup: Record "User Setup";
        UserSetup2: Record "User Setup";
        LineNo: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ReportSelection: Record "Report Selections";
        DocNumber: Code[20];
        Loc: Record Location;
        LocationCODE: Code[10];
        Text000: label 'Posting lines         #2######';
        TotalPerDiemAmt: Decimal;
        TotalPerDiemDays: Integer;
        TaxablePerDiemAmt: Decimal;
        DailyNonTaxablePerDiemAmt: Decimal;
        HRSetup: Record "Human Resources Setup";
        PostedTravelHeader: Record "Posted Travel Request Header";
        PostedTravelLine: Record "Posted Travel Request Line";
        RequesterEmail: Text[50];
        TravelGrade: Record "Employee Travel Grade";
        Employee: Record Employee;
        PerDiemCount: Integer;
        GenJnlPage: Page "General Journal";
        StoresOfficerEmail: Code[50];
        i: Integer;
        DocNo: Code[30];
        Text004: label 'Travel Requisition number %1 has been generated to Order number %2.';
        DimMgt: Codeunit DimensionManagement;
        /* AssetLine: Record UnknownRecord50014; */
        LuserEmail: Code[60];
        Email: Codeunit "SMTP Mail";
        EmailSubject: Text[100];
        EmailMessage: Text[100];
        EmailUserData: Text[100];
        /* ContractMatrix: Record UnknownRecord50078; */
        PurchHeader: Record "Purchase Header";
        /*  ContLines: Record UnknownRecord50076; */
        PurchOrderCard: Page "Purchase Order";
        PurchaseCard: Page "Purchase Order";
        SubstituteApprover: Record "User Setup";
        /* PeriodSetup: Record UnknownRecord51127; */
        CurrentPeriod: Option " ",Qtr1,Qtr2,Qtr3,Qtr4;
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";

    procedure PostTravel(var TravelReqHeader: Record "Travel Request Header")
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin
        with TravelReqHeader do begin
            //TESTFIELD(Department);

            if "Currency Code" = 'USD' then begin
                GenJnlBatch.Reset;
                GenJnlBatch.SetCurrentkey("Journal Template Name", Name);
                GenJnlBatch.SetRange("Journal Template Name", 'PAYMENTS');
                GenJnlBatch.SetRange(Name, 'PERDIEMLCY');
            end
            else
                if "Currency Code" = '' then begin
                    GenJnlBatch.Reset;
                    GenJnlBatch.SetCurrentkey("Journal Template Name", Name);
                    GenJnlBatch.SetRange("Journal Template Name", 'PAYMENTS');
                    GenJnlBatch.SetRange(Name, 'PERDIEMLCY');
                end;

            if GenJnlBatch.FindFirst then begin
                LineNo := GetGenJnlLastLineNo(GenJnlBatch);

                DocNumber := "No.";

                //Inserting Travel Lines to the journal
                JournalTransfer(TravelReqHeader, GenJnlBatch, LineNo, DocNumber);

                /*
                GenJnlLine.RESET;
                GenJnlLine.SETCURRENTKEY("Journal Template Name","Journal Batch Name","Line No.");
                GenJnlLine.SETRANGE("Journal Template Name",GenJnlBatch."Journal Template Name");
                GenJnlLine.SETRANGE("Journal Batch Name",GenJnlBatch.Name);
                IF GenJnlLine.FINDFIRST THEN BEGIN
                  GenJnlPostBatch.RUN(GenJnlLine);
                  CLEAR(GenJnlLine);
                  CLEAR(GenJnlPostBatch);
                  MODIFY;
                END;
                */
            end;
        end;

    end;

    procedure JournalTransfer(var TravelReqHeader: Record "Travel Request Header"; var GenJnlBatch: Record "Gen. Journal Batch"; LineNo: Integer; DocNo: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
        TravelLine: Record "Travel Request Line";
        TravelLine2: Record "Travel Request Line";
        TravelLine3: Record "Travel Request Line";
        HRSetup: Record "Human Resources Setup";
        Customer: Record Customer;
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        LUser3: Record "User Setup";
        PerDiemTypeAmt: Decimal;
    begin
        HRSetup.Get;

        with TravelReqHeader do begin

            TotalPerDiemAmt := 0;
            TravelLine.Reset;
            TravelLine.SetCurrentkey("Document No.", "Line No.");
            TravelLine.SetRange("Document No.", "No.");
            TravelLine.SetRange("Entry Type", TravelLine."entry type"::"Per Diem");
            if TravelLine.FindSet then
                repeat
                    TotalPerDiemAmt += TravelLine."Total Amount";
                until TravelLine.Next = 0;

            PerDiemCount := 0;

            TravelLine2.Reset;
            TravelLine2.SetCurrentkey("Document No.", "Line No.");
            TravelLine2.SetRange("Document No.", "No.");
            TravelLine2.SetRange("Entry Type", TravelLine2."entry type"::"Per Diem");
            TravelLine2.SetRange("PerDiem Type", TravelLine2."perdiem type"::"OUT OF POCKET");
            PerDiemCount := TravelLine2.Count;

            TotalPerDiemDays := 0;
            DailyNonTaxablePerDiemAmt := 0;
            TaxablePerDiemAmt := 0;

            TravelLine3.Reset;
            TravelLine3.SetCurrentkey("Document No.", "Line No.");
            TravelLine3.SetRange("Document No.", "No.");
            TravelLine3.SetRange("Entry Type", TravelLine3."entry type"::"Per Diem");
            if TravelLine3.FindFirst then
                TotalPerDiemDays := TravelLine3.Quantity;

            DailyNonTaxablePerDiemAmt := (PerDiemCount * HRSetup."Tax Threshold");
            TaxablePerDiemAmt := TotalPerDiemAmt - DailyNonTaxablePerDiemAmt;

            //inserting non taxable per diem
            if DailyNonTaxablePerDiemAmt <> 0 then begin
                GenJnlLine.Reset;
                GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
                GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
                GenJnlLine."Line No." := LineNo;
                GenJnlLine.Validate("Posting Date", Today);
                GenJnlLine.Validate("Document Type", GenJnlLine."document type"::Payment);
                if GenJnlBatch."No. Series" <> '' then
                    GenJnlLine."Document No." :=
                                NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", "Raised Date", false);
                GenJnlLine."External Document No." := "No.";
                GenJnlLine."Payment Method Code" := 'CASH';
                GenJnlLine.Insert(true);


                GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"G/L Account");

                if "Currency Code" = '' then
                    GenJnlLine."Account No." := HRSetup."LCY Per Diem AC"
                else
                    if "Currency Code" = 'USD' then begin
                        GenJnlLine.Validate("Currency Code", 'USD');
                        GenJnlLine."Account No." := HRSetup."USD Per Diem AC";
                    end;

                GenJnlLine.Validate("Account No.");

                GenJnlLine.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type");
                GenJnlLine.Validate("Bal. Account No.", GenJnlBatch."Bal. Account No.");
                GenJnlLine.Validate("Shortcut Dimension 1 Code", Branch);
                GenJnlLine.Validate("Shortcut Dimension 2 Code", Department);

                GenJnlLine.Validate(Amount, DailyNonTaxablePerDiemAmt);
                GenJnlLine.Modify;

                LineNo := LineNo + 10000;
            end;

            //inserting taxable per diem
            if TaxablePerDiemAmt > 0 then begin
                GenJnlLine.Reset;
                GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
                GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
                GenJnlLine."Line No." := LineNo;
                GenJnlLine.Validate("Posting Date", Today);
                GenJnlLine.Validate("Document Type", GenJnlLine."document type"::Payment);
                if GenJnlBatch."No. Series" <> '' then
                    GenJnlLine."Document No." :=
                                NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", "Raised Date", false);
                GenJnlLine."External Document No." := "No.";

                GenJnlLine.Insert(true);


                GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"G/L Account");

                /*
                  //Get Staff Account from user card
                  Customer.INIT;
                  Customer.GET("Employee No.");

                  GenJnlLine.VALIDATE("Account No.", Customer."No.");
                  */


                if "Currency Code" = '' then
                    GenJnlLine."Account No." := HRSetup."Staff Debtors"
                else
                    if "Currency Code" = 'USD' then begin
                        GenJnlLine.Validate("Currency Code", 'USD');
                        GenJnlLine."Account No." := HRSetup."Staff Debtors"
                    end;

                GenJnlLine.Validate("Account No.");
                GenJnlLine.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type");
                GenJnlLine.Validate("Bal. Account No.", GenJnlBatch."Bal. Account No.");
                GenJnlLine.Validate("Shortcut Dimension 1 Code", Branch);
                GenJnlLine.Validate("Shortcut Dimension 2 Code", Department);
                GenJnlLine."Payment Method Code" := 'CASH';
                GenJnlLine.Validate(Amount, TaxablePerDiemAmt);
                GenJnlLine.Modify;

                LineNo := LineNo + 10000;
            end;

            //sending email notification to finance team

            if HRSetup."Enable Travel Notifications" then begin

                LUser.Get(UserId);
                LUser2.Get("HRBP Approver");
                LUser3.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                PerDiemTypeAmt := 0;
                TravelLine2.Reset;
                TravelLine2.SetRange("Document No.", "No.");
                TravelLine2.SetRange("Entry Type", TravelLine2."entry type"::"Per Diem");
                if TravelLine2.FindSet then
                    repeat
                        PerDiemTypeAmt += TravelLine2."Total Amount";
                    until TravelLine2.Next = 0;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if HRSetup."Finance Admin Email" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', HRSetup."Finance Admin Email",
                                                'Travel Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved travel request. The per diem amount have been inserted into the payment journal for your action');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel Requester :   ' + UpperCase("Raised By" + CRLF));
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('Per Diem Amount :   ' + (Format(PerDiemTypeAmt) + CRLF));


                        /*                         if LUser2."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser2."E-Mail");

                                                if LUser3."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser3."E-Mail"); */



                        LSMTPMail.Send;
                    end;
                end;
            end;
        end;


    end;

    procedure GetGenJnlLastLineNo(var GenJnlBatch: Record "Gen. Journal Batch") LastLineNo: Integer
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        Clear(LastLineNo);
        with GenJnlBatch do begin
            GenJnlLine.Reset;
            GenJnlLine.SetCurrentkey("Journal Template Name", "Journal Batch Name", "Line No.");
            GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", Name);
            if GenJnlLine.FindLast then
                LastLineNo := GenJnlLine."Line No." + 10000
            else
                LastLineNo := 10000;
        end;
        exit(LastLineNo);
    end;

    procedure PrintVoucher(var TravelReqHeader: Record "Travel Request Header")
    var
        TravelHdr: Record "Travel Request Header";
        TravelRpt: Report "Sales Invoice Nos.";
    begin
        with TravelReqHeader do begin
            Clear(TravelRpt);
            TravelHdr.Reset;
            TravelHdr.SetCurrentkey("No.");
            TravelHdr.SetRange("No.", "No.");
            TravelRpt.SetTableview(TravelHdr);
            TravelRpt.Run;
        end;
    end;

    procedure SubmitTravelForApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if Approver = '' then
                Error('Please select the travel approver for this requisition');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin

                LUser.Get(UserId);
                LUser2.Get(Approver);

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Travel Approval Request -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has submitted a travel request that requires your  approval in ERP system');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::"Pending Approval";
            "Submit Date" := Today;
            Modify;
            Message('Approval submitted successfully');

        end;
    end;

    procedure SubmitForHRTravelApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "HR Manager Approver" = '' then
                Error('Please select the HR travel approver for this requisition');

            if "Approval Status" <> "approval status"::Approved then
                Error('Only approved travel requests can be sent for further approvals');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("HR Manager Approver");
                "HR Mgr App Date" := Today;

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Travel Approval Request -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has submitted a travel request for that requires your approval.  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel Requester :   ' + UpperCase("Raised By" + CRLF));
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "HR Approval Status" := "hr approval status"::"Pending Approval";
            "HRBP Approver" := UserId;
            "HR Submit Date" := Today;
            Modify;
            Message('Approval submitted successfully');

        end;
    end;

    procedure ApproveTravelApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending Approval" then
                Error('Only pending travel requests can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Travel Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your travel request.  The request is being prepared to be sent for final approval  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Approved;
            "Approval By" := UserId;
            "Line App Date" := Today;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure DisapproveTravelApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Remarks" = '' then
                Error('Please insert disapproval remarks for this travel request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Travel Request Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your travel request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approval Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Disapproved;
            "Approval By" := UserId;
            "Line App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure ApproveHRTravelApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        LUser3: Record "User Setup";
    begin
        with TravelReqHeader do begin

            PostTravel(TravelReqHeader);

            HRSetup.Get;

            if "HR Approval Status" <> "hr approval status"::"Pending Approval" then
                Error('Only pending travel requests can be approved');

            //sending email notification to HR and requestor
            if HRSetup."Enable Travel Notifications" then begin

                LUser.Get(UserId);
                LUser2.Get("HRBP Approver");
                LUser3.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Travel Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved travel request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel Requester :   ' + UpperCase("Raised By" + CRLF));
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));

                        /*                         if LUser2."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser2."E-Mail");

                                                if LUser3."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser3."E-Mail"); */

                        LSMTPMail.Send;
                    end;
                end;
            end;

            //sending email notification to ticketing admin
            if HRSetup."Enable Travel Notifications" then begin

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if HRSetup."Ticketing Admin Email" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', HRSetup."Ticketing Admin Email",
                                                'Travel Request Approved For Ticketing -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved travel request below for ticketing.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel Requester :   ' + UpperCase("Raised By" + CRLF));
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Mode :   ' + UpperCase(Format("Travel Mode") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));

                        /*                         if LUser2."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser2."E-Mail");

                                                if LUser3."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser3."E-Mail");
                         */
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "HR Approval Status" := "hr approval status"::Approved;
            "HR Approval By" := UserId;
            "HRBP App Date" := Today;
            Modify;

            //create purchase order for accomodation
            if ("Accomodation Type" = "accomodation type"::Company) and ("Accomodation Vendor No." <> '') then
                CreateAccomodationPurchaseOrder(TravelReqHeader);

            //create purchase order for accomodation
            if ("Travel Mode" <> "travel mode"::Company) and ("Travel Vendor No." <> '') then
                CreateTravelPurchaseOrder(TravelReqHeader);

            //send to posted travel requests
            PostedTravelHeader.Init;
            PostedTravelHeader.TransferFields(TravelReqHeader);
            PostedTravelHeader.Insert;

            TravelLine.Reset;
            TravelLine.SetRange("Document No.", "No.");
            if TravelLine.FindSet then begin
                repeat
                    PostedTravelLine.Reset;
                    PostedTravelLine.TransferFields(TravelLine);
                    PostedTravelLine."Document No." := TravelLine."Document No.";
                    PostedTravelLine.Insert;
                until TravelLine.Next = 0;
            end;
            //DELETE(TRUE);

            Message('Approval Successful');

        end;
    end;

    procedure DisapproveHRTravelApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "HR Approval Remarks" = '' then
                Error('Please insert disapproval remarks for this travel request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("HRBP Approver");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Travel Request Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved travel request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel Requester :   ' + UpperCase("Raised By" + CRLF));
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approval Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "HR Approval Status" := "hr approval status"::Disapproved;
            "HR Approval By" := UserId;
            "HRBP App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure CreateAccomodationPurchaseOrder(var TravelReqHeader: Record "Travel Request Header")
    var
        TravelReqLine: Record "Travel Request Line";
        PurchOrderHeader: Record "Purchase Header";
        PurchOrderLine: Record "Purchase Line";
        PurchOrderHeader2: Record "Purchase Header";
        NextLineNo: Integer;
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LUser3: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        i := 0;
        HRSetup.Get;
        with TravelReqHeader do begin
            PurchOrderHeader.Init;
            PurchOrderHeader."No." := '';
            PurchOrderHeader."Document Type" := PurchOrderHeader."document type"::Order;
            /* PurchOrderHeader."Document Subtype" := PurchOrderHeader."document subtype"::Service; */
            PurchOrderHeader.Validate("Posting Date", Today);
            PurchOrderHeader.Insert(true);

            PurchOrderHeader.Validate("Buy-from Vendor No.", "Accomodation Vendor No.");
            PurchOrderHeader.Validate("Order Date", Today);
            PurchOrderHeader."Quote No." := "No.";
            PurchOrderHeader.Modify;
            i += 1;
            DocNo := PurchOrderHeader."No.";

            PurchOrderHeader2.Init;
            PurchOrderHeader2.SetRange("Buy-from Vendor No.", "Accomodation Vendor No.");
            if PurchOrderHeader2.FindLast then;

            TravelLine.Reset;
            TravelLine.SetRange("Document No.", "No.");
            TravelLine.SetRange("Entry Type", TravelLine."entry type"::Accomodation);
            if TravelLine.FindSet then
                repeat
                    PurchOrderLine.Init;
                    PurchOrderLine."Document Type" := PurchOrderLine."document type"::Order;
                    PurchOrderLine."Document No." := PurchOrderHeader."No.";
                    NextLineNo := NextLineNo + 10000;
                    PurchOrderLine."Line No." := NextLineNo;
                    PurchOrderLine.Type := PurchOrderLine.Type::"G/L Account";
                    PurchOrderLine.Validate("No.", HRSetup."Accomodation Account");
                    PurchOrderLine.Description := 'ACCOMODATION FOR - ' + "Raised By";
                    PurchOrderLine.Validate(Quantity, TravelLine.Quantity);
                    PurchOrderLine.Validate("Direct Unit Cost", TravelLine."Unit Amount");
                    PurchOrderLine.Insert;
                until TravelLine.Next = 0;

            Commit;
            //Confirmation message
            if i = 1 then begin
                Message(Text004,
                    "No.", PurchOrderHeader."No.")
            end;
            //notification to procurement
            HRSetup.Get;

            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("HRBP Approver");
                LUser3.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if HRSetup."Procurement Admin Email" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', HRSetup."Procurement Admin Email",
                                                'Travel Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved travel request. A purchase order for accomodation has also been created with detail as below for your action.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel Requester :   ' + UpperCase("Raised By" + CRLF));
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approval Remarks" + CRLF));
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('Purchase Order No. :   ' + (PurchOrderHeader2."No." + CRLF));

                        /*                         if LUser2."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser2."E-Mail");

                                                if LUser3."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser3."E-Mail"); */

                        LSMTPMail.Send;
                    end;
                end;
            end;

        end;
    end;

    procedure CreateTravelPurchaseOrder(var TravelReqHeader: Record "Travel Request Header")
    var
        TravelReqLine: Record "Travel Request Line";
        PurchOrderHeader: Record "Purchase Header";
        PurchOrderLine: Record "Purchase Line";
        PurchOrderHeader2: Record "Purchase Header";
        NextLineNo: Integer;
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LUser3: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        HRSetup.Get;
        with TravelReqHeader do begin
            PurchOrderHeader.Init;
            PurchOrderHeader."No." := '';
            PurchOrderHeader."Document Type" := PurchOrderHeader."document type"::Order;
            /* PurchOrderHeader."Document Subtype" := PurchOrderHeader."document subtype"::Service; */
            PurchOrderHeader.Validate("Posting Date", Today);
            PurchOrderHeader.Insert(true);

            PurchOrderHeader.Validate("Buy-from Vendor No.", "Travel Vendor No.");
            PurchOrderHeader.Validate("Order Date", Today);
            PurchOrderHeader."Quote No." := "No.";
            PurchOrderHeader.Modify;

            PurchOrderHeader2.Init;
            PurchOrderHeader2.SetRange("Buy-from Vendor No.", "Travel Vendor No.");
            if PurchOrderHeader2.FindLast then;

            TravelLine.Reset;
            TravelLine.SetRange("Document No.", "No.");
            TravelLine.SetRange("Entry Type", TravelLine."entry type"::Travel);
            if TravelLine.FindSet then
                repeat
                    PurchOrderLine.Init;
                    PurchOrderLine."Document Type" := PurchOrderLine."document type"::Order;
                    PurchOrderLine."Document No." := PurchOrderHeader."No.";
                    NextLineNo := NextLineNo + 10000;
                    PurchOrderLine."Line No." := NextLineNo;
                    PurchOrderLine.Type := PurchOrderLine.Type::"G/L Account";
                    PurchOrderLine.Validate("No.", HRSetup."Accomodation Account");
                    PurchOrderLine.Description := 'TRAVEL FOR - ' + "Raised By";
                    PurchOrderLine.Validate(Quantity, 1);
                    PurchOrderLine.Validate("Direct Unit Cost", TravelLine."Total Amount");
                    PurchOrderLine.Insert;
                until TravelLine.Next = 0;


            //notification to procurement
            HRSetup.Get;

            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("HRBP Approver");
                LUser3.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if HRSetup."Procurement Admin Email" <> '' then begin
                        LSMTPMail.CreateMessage('Travel Management', 'erpNotifications@gab.co.ke', HRSetup."Procurement Admin Email",
                                                'Travel Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved travel request. A purchase order for travel has also been created with detail as below for your action.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('TRAVEL REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.AppendBody('Travel Requester :   ' + UpperCase("Raised By" + CRLF));
                        LSMTPMail.AppendBody('Travel From - To :   ' + UpperCase("Travel From" + ' - ' + "Travel To" + CRLF));
                        LSMTPMail.AppendBody('Travel Dates :   ' + UpperCase(Format("Travel From Date") + ' - ' + Format("Travel To Date") + CRLF));
                        LSMTPMail.AppendBody('Travel Purpose :   ' + UpperCase("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approval Remarks" + CRLF));
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('Purchase Order No. :   ' + (PurchOrderHeader2."No." + CRLF));

                        /*                         if LUser2."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser2."E-Mail");

                                                if LUser3."E-Mail" <> '' then
                                                    LSMTPMail.AddCC(LUser3."E-Mail"); */

                        LSMTPMail.Send;
                    end;
                end;
            end;

        end;
    end;

    /*  procedure ApprovePOApproval(var POHeader: Record "Purchase Header")
     var
         LSMTPMailSetup: Record "SMTP Mail Setup";
         LUser: Record "User Setup";
         LUser2: Record "User Setup";
         LSMTPMail: Codeunit "SMTP Mail";
         CRLF: Text[30];
         LFullName: Text[120];
         LEmployee: Record Employee;
     begin
         with POHeader do begin
             HRSetup.Get;

             if Status <> Status::"Pending Approval" then
                 Error('Only pending PO can be approved');

             //sending email notification
             if HRSetup."Enable Travel Notifications" then begin
                 LUser.Get(UserId);
                 LUser2.Get("Created By USER ID");

                 LEmployee.Init;
                 if LEmployee.Get(LUser."Employee No.") then
                     LFullName := LEmployee.FullName;

                 CRLF := '';
                 CRLF[1] := 13;
                 CRLF[2] := 10;

                 if LSMTPMailSetup.Get then begin
                     if LUser2."E-Mail" <> '' then begin
                         LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                 'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                         LSMTPMail.AppendBody(' has approved your PO.  The PO is being prepared to be sent for HOD approval');
                         LSMTPMail.AppendBody(CRLF + CRLF);
                         LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                         LSMTPMail.AppendBody(CRLF);
                         LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                         LSMTPMail.Send;
                     end;
                 end;
             end;

             Status := Status::"Pending HOD Approval";
             "Proc Approver" := UserId;
             "Proc App Date" := Today;
             Modify;
             Message('Approval Successful');

         end;
     end;

     procedure POHODApproval(var POHeader: Record "Purchase Header")
     var
         LSMTPMailSetup: Record "SMTP Mail Setup";
         LUser: Record "User Setup";
         LUser2: Record "User Setup";
         LSMTPMail: Codeunit "SMTP Mail";
         CRLF: Text[30];
         LFullName: Text[120];
         LEmployee: Record Employee;
     begin
         with POHeader do begin
             HRSetup.Get;

             if Status <> Status::"Pending HOD Approval" then
                 Error('Only pending PO can be approved');

             //sending email notification
             if HRSetup."Enable Travel Notifications" then begin
                 LUser.Get(UserId);
                 LUser2.Get("Created By USER ID");

                 LEmployee.Init;
                 if LEmployee.Get(LUser."Employee No.") then
                     LFullName := LEmployee.FullName;

                 CRLF := '';
                 CRLF[1] := 13;
                 CRLF[2] := 10;

                 if LSMTPMailSetup.Get then begin
                     if LUser2."E-Mail" <> '' then begin
                         LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                 'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                         LSMTPMail.AppendBody(' has approved your PO.  The PO is being prepared to be sent for HOD Finance approval');
                         LSMTPMail.AppendBody(CRLF + CRLF);
                         LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                         LSMTPMail.AppendBody(CRLF);
                         LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                         LSMTPMail.Send;
                     end;
                 end;
             end;

             Status := Status::"Pending Finance Approval";
             "HOD Approver" := UserId;
             "HOD App Date" := Today;
             Modify;
             Message('Approval Successful');

         end;
     end;

     procedure POFinanceApproval(var POHeader: Record "Purchase Header")
     var
         LSMTPMailSetup: Record "SMTP Mail Setup";
         LUser: Record "User Setup";
         LUser2: Record "User Setup";
         LSMTPMail: Codeunit "SMTP Mail";
         CRLF: Text[30];
         LFullName: Text[120];
         LEmployee: Record Employee;
     begin
         with POHeader do begin
             HRSetup.Get;

             if Status <> Status::"Pending Finance Approval" then
                 Error('Only pending PO can be approved');

             //sending email notification
             if HRSetup."Enable Travel Notifications" then begin
                 LUser.Get(UserId);
                 LUser2.Get("Created By USER ID");

                 LEmployee.Init;
                 if LEmployee.Get(LUser."Employee No.") then
                     LFullName := LEmployee.FullName;

                 CRLF := '';
                 CRLF[1] := 13;
                 CRLF[2] := 10;

                 if LSMTPMailSetup.Get then begin
                     if LUser2."E-Mail" <> '' then begin
                         LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                 'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                         LSMTPMail.AppendBody(' has approved your PO.  The PO is now ready  to be sent to the supplier');
                         LSMTPMail.AppendBody(CRLF + CRLF);
                         LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                         LSMTPMail.AppendBody(CRLF);
                         LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                         LSMTPMail.Send;
                     end;
                 end;
             end;

             if "Managing Director" <> '' then begin
                 Status := Status::"Pending MD Approval";
                 "Finance Approver" := UserId;
                 "Fin App Date" := Today;
                 Modify;
                 Message('Approval Successful');

             end else begin
                 Status := Status::Released;
                 "Finance Approver" := UserId;
                 // "Approval Date" := TODAY;
                 Modify;
                 Message('Approval Successful');
             end;
         end;
     end;

     procedure DisapprovePOApproval(var POHeader: Record "Purchase Header")
     var
         LSMTPMailSetup: Record "SMTP Mail Setup";
         LUser: Record "User Setup";
         LUser2: Record "User Setup";
         LSMTPMail: Codeunit "SMTP Mail";
         CRLF: Text[30];
         LFullName: Text[120];
         LEmployee: Record Employee;
     begin
         with POHeader do begin
             HRSetup.Get;

             if "Approver Remarks" = '' then
                 Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

             //sending email notification
             if HRSetup."Enable Travel Notifications" then begin
                 LUser.Get(UserId);
                 LUser2.Get("Created By USER ID");

                 LEmployee.Init;
                 if LEmployee.Get(LUser."Employee No.") then
                     LFullName := LEmployee.FullName;

                 CRLF := '';
                 CRLF[1] := 13;
                 CRLF[2] := 10;

                 if LSMTPMailSetup.Get then begin
                     if LUser2."E-Mail" <> '' then begin
                         LSMTPMail.CreateMessage('Purchase Order  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                 'PO Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                         LSMTPMail.AppendBody(' has disapproved your PO request.');
                         LSMTPMail.AppendBody(CRLF + CRLF);
                         LSMTPMail.AppendBody('PO  REQUEST DETAILS' + CRLF);
                         LSMTPMail.AppendBody(CRLF);
                         LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);

                         LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                         LSMTPMail.Send;
                     end;
                 end;
             end;

             Status := Status::Dissaproved;
             "Proc Approver" := UserId;
             "Proc App Date" := Today;
             Modify;
             Message('Disapproval successful');

         end;
     end;

     procedure DisapproveHODApproval(var POHeader: Record "Purchase Header")
     var
         LSMTPMailSetup: Record "SMTP Mail Setup";
         LUser: Record "User Setup";
         LUser2: Record "User Setup";
         LSMTPMail: Codeunit "SMTP Mail";
         CRLF: Text[30];
         LFullName: Text[120];
         LEmployee: Record Employee;
     begin
         with POHeader do begin
             HRSetup.Get;

             if "Approver Remarks" = '' then
                 Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

             //sending email notification
             if HRSetup."Enable Travel Notifications" then begin
                 LUser.Get(UserId);
                 LUser2.Get("Created By USER ID");

                 LEmployee.Init;
                 if LEmployee.Get(LUser."Employee No.") then
                     LFullName := LEmployee.FullName;

                 CRLF := '';
                 CRLF[1] := 13;
                 CRLF[2] := 10;

                 if LSMTPMailSetup.Get then begin
                     if LUser2."E-Mail" <> '' then begin
                         LSMTPMail.CreateMessage('Purchase Order  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                 'PO Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                         LSMTPMail.AppendBody(' has disapproved your PO request.');
                         LSMTPMail.AppendBody(CRLF + CRLF);
                         LSMTPMail.AppendBody('PO  REQUEST DETAILS' + CRLF);
                         LSMTPMail.AppendBody(CRLF);
                         LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);

                         LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                         LSMTPMail.Send;
                     end;
                 end;
             end;

             Status := Status::Dissaproved;
             "HOD Approver" := UserId;
             "HOD App Date" := Today;
             Modify;
             Message('Disapproval successful');

         end;
     end;

     procedure DisapproveFinanceApproval(var POHeader: Record "Purchase Header")
     var
         LSMTPMailSetup: Record "SMTP Mail Setup";
         LUser: Record "User Setup";
         LUser2: Record "User Setup";
         LSMTPMail: Codeunit "SMTP Mail";
         CRLF: Text[30];
         LFullName: Text[120];
         LEmployee: Record Employee;
     begin
         with POHeader do begin
             HRSetup.Get;

             if "Approver Remarks" = '' then
                 Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

             //sending email notification
             if HRSetup."Enable Travel Notifications" then begin
                 LUser.Get(UserId);
                 LUser2.Get("Created By USER ID");

                 LEmployee.Init;
                 if LEmployee.Get(LUser."Employee No.") then
                     LFullName := LEmployee.FullName;

                 CRLF := '';
                 CRLF[1] := 13;
                 CRLF[2] := 10;

                 if LSMTPMailSetup.Get then begin
                     if LUser2."E-Mail" <> '' then begin
                         LSMTPMail.CreateMessage('Purchase Order  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                 'PO Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                         LSMTPMail.AppendBody(' has disapproved your PO request.');
                         LSMTPMail.AppendBody(CRLF + CRLF);
                         LSMTPMail.AppendBody('PO  REQUEST DETAILS' + CRLF);
                         LSMTPMail.AppendBody(CRLF);
                         LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);

                         LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                         LSMTPMail.Send;
                     end;
                 end;
             end;

             Status := Status::Dissaproved;
             "Finance Approver" := UserId;
             "Fin App Date" := Today;
             Modify;
             Message('Disapproval successful');

         end;
     end;
  */
    /* procedure ApprovePRApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with PRHeader do begin
            HRSetup.Get;

            if Status <> Status::"Pending Line Managerl" then
                Error('Only pending PR can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your PR.  The PR is being prepared to be sent for finance approval');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            if ("Nature of Request" <> "nature of request"::Others) then begin

                Status := Status::"Pending Technical Approval";
                "Line Approval" := UserId;
                "Line Mgr App Date" := Today;
                Modify;
            end else
                if "Shortcut Dimension 1 Code" <> '500' then begin
                    Status := Status::"Pending Finance Approval";
                    "Line Approval" := UserId;
                    "Line Mgr App Date" := Today;
                    Modify;
                    Message('Approval Successful');
                end else
                    if "Shortcut Dimension 1 Code" = '500' then begin
                        Status := Status::Released;
                        "Line Approval" := UserId;
                        "Line Mgr App Date" := Today;
                        Modify;
                        Message('Approval Successful');


                        "Shortcut Dimension 1 Code" := GetUrl(Clienttype::Windows, COMPANYNAME, Objecttype::Page, 51100, PRHeader."No.", true);


                    end

        end;





        ////
    end;

    procedure PRHODFinanceApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        BPRHeader: Record UnknownRecord51131;
        BPRLines: Record UnknownRecord51132;
        PurchaseRHeader: Record UnknownRecord51100;
        PurchaseRLines: Record UnknownRecord51101;
        BudgetSetup: Record UnknownRecord51126;
        FASetup: Record "FA Posting Group";
        FixedAsset: Record "Fixed Asset";
        Item: Record Item;
        ItemSetup: Record "Inventory Posting Setup";
    begin
        with PRHeader do begin
            HRSetup.Get;

            if Status <> Status::"Pending HOD Finance" then
                Error('Only pending PR can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        //LSMTPMail.AddCC('info@ujuzitech.com');
                        LSMTPMail.AppendBody(' has approved your PR.  The PR has been sent to Procurement for processing');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            //END Mails
            //BKR 30.01.2020

            BudgetSetup.Get;

            PeriodSetup.Reset;
            PeriodSetup.SetRange("Active Budget", BudgetSetup."Active Budget");
            if PeriodSetup.FindFirst then
                case PeriodSetup.Period of
                    PeriodSetup.Period::Qtr1:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr1;
                    PeriodSetup.Period::Qtr2:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr2;

                    PeriodSetup.Period::Qtr3:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr3;

                    PeriodSetup.Period::Qtr4:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr4;
                end;

            PurchaseRLines.Reset;
            PurchaseRLines.SetRange("Document No.", "No.");

            //PurchaseRLines.SETFILTER("Activity Code",'%1',PurchaseRLines."Activity Code");
            if PurchaseRLines.FindFirst then begin

                repeat
                    if (PurchaseRLines."Budgeted Line" = true) or (PurchaseRLines."Activity Code" <> '') then begin
                        //If type G/L Account
                        if PurchaseRLines.Type = PurchaseRLines.Type::"G/L Account" then begin
                            BPRHeader.Reset;
                            BPRHeader.SetRange("Budget Name", BudgetSetup."Active Budget");
                            BPRHeader.SetRange("Shortcut Dimension 2 Code", PurchaseRLines."Shortcut Dimension 2 Code");
                            BPRHeader.SetRange(Status, BPRHeader.Status::Approved);
                            if BPRHeader.FindFirst then begin

                                BPRLines.Reset;
                                BPRLines.SetRange("Budget Name", BudgetSetup."Active Budget");
                                BPRLines.SetRange("Global Dimension 2 Code", BPRHeader."Shortcut Dimension 2 Code");
                                BPRLines.SetRange("G/L Account No.", PurchaseRLines."No.");
                                BPRLines.SetRange(Period, CurrentPeriod);
                                BPRLines.SetRange("Activity Code", PurchaseRLines."Activity Code");
                                //ERROR(FORMAT(BPRLines."Budget Name"));
                                if BPRLines.FindFirst then begin
                                    repeat
                                        BPRLines."Consumed Amount" := BPRLines."Consumed Amount" + PurchaseRLines."Line Amount";
                                        BPRLines.Modify;
                                    until BPRHeader.Next = 0;
                                end
                            end
                        end
                        //If type item
                        else
                            if PurchaseRLines.Type = PurchaseRLines.Type::Item then begin

                                Item.Reset;
                                Item.SetRange(Item."No.", PurchaseRLines."No.");
                                if Item.FindFirst then
                                    if Item."Inventory Posting Group" <> '' then begin
                                        ItemSetup.SetRange("Invt. Posting Group Code", Item."Inventory Posting Group");
                                        ItemSetup.SetRange("Location Code", PurchaseRLines."Location Code");
                                        if ItemSetup.FindFirst then
                                            if
                  ItemSetup."Inventory Account" <> '' then begin
                                                BPRHeader.Reset;
                                                BPRHeader.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                BPRHeader.SetRange("Shortcut Dimension 2 Code", PurchaseRLines."Shortcut Dimension 2 Code");
                                                BPRHeader.SetRange(Status, BPRHeader.Status::Approved);
                                                if BPRHeader.FindFirst then begin

                                                    BPRLines.Reset;
                                                    BPRLines.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                    BPRLines.SetRange("Global Dimension 2 Code", BPRHeader."Shortcut Dimension 2 Code");
                                                    BPRLines.SetRange(Period, CurrentPeriod);
                                                    BPRLines.SetRange("Activity Code", PurchaseRLines."Activity Code");
                                                    BPRLines.SetRange("G/L Account No.", ItemSetup."Inventory Account");
                                                    if BPRLines.FindFirst then begin
                                                        begin
                                                            repeat
                                                                BPRLines."Consumed Amount" := BPRLines."Consumed Amount" + PurchaseRLines."Line Amount";
                                                                BPRLines.Modify;
                                                            until BPRLines.Next = 0;
                                                        end
                                                    end
                                                end
                                            end

                                    end
                                    //If type Fixed Asset
                                    else
                                        if PurchaseRLines.Type = PurchaseRLines.Type::"Fixed Asset" then begin
                                            FixedAsset.Reset;
                                            FixedAsset.SetRange(FixedAsset."No.", PurchaseRLines."No.");
                                            if FixedAsset.FindFirst then
                                                if FixedAsset."FA Posting Group" <> '' then begin
                                                    FASetup.SetRange(Code, FixedAsset."FA Posting Group");
                                                    if FASetup.FindFirst then
                                                        if
                                FASetup."Acquisition Cost Account" <> '' then begin
                                                            BPRHeader.Reset;
                                                            BPRHeader.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                            BPRHeader.SetRange("Shortcut Dimension 2 Code", PurchaseRLines."Shortcut Dimension 2 Code");
                                                            BPRHeader.SetRange(Status, BPRHeader.Status::Approved);
                                                            if BPRHeader.FindFirst then begin

                                                                BPRLines.Reset;
                                                                BPRLines.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                                BPRLines.SetRange("Global Dimension 2 Code", BPRHeader."Shortcut Dimension 2 Code");
                                                                BPRLines.SetRange(Period, CurrentPeriod);
                                                                BPRLines.SetRange("Activity Code", PurchaseRLines."Activity Code");
                                                                BPRLines.SetRange("G/L Account No.", FASetup."Acquisition Cost Account");
                                                                if BPRLines.FindFirst then begin
                                                                    repeat
                                                                        BPRLines."Consumed Amount" := BPRLines."Consumed Amount" + PurchaseRLines."Line Amount";
                                                                        BPRLines.Modify;
                                                                    until BPRLines.Next = 0;
                                                                end
                                                            end
                                                        end
                                                end
                                        end;

                                PurchaseRLines."Budgeted Line" := true;
                                PurchaseRLines.Modify;
                                //end of PurchaseRLines."Budgeted Line";
                            end
                    end
                until PurchaseRLines.Next = 0;
            end;
            //BKR END

            //BKR 25/03/2020
            PurchasesPayablesSetup.Get;
            CalcFields("RMT Total Amount Inc. VAT");
            if "Document Type" = "document type"::"Purchase Requisition" then begin
                if "Document Subtype" = "document subtype"::CAPEX then begin
                    if PurchasesPayablesSetup."Capex Amount" > "RMT Total Amount Inc. VAT" then begin
                        Status := Status::Released;
                        "HOD Finance" := UserId;
                        "HOD Finance App Date" := Today;
                        Modify;
                        Message('Approval Successful');

                    end else begin
                        Status := Status::"Pending MD approval";
                        "HOD Finance" := UserId;
                        "HOD Finance App Date" := Today;
                        Modify;
                        Message('Approval Successful');
                        //sending email notification
                        if HRSetup."Enable Travel Notifications" then begin
                            LUser.Get(UserId);
                            LUser2.Get("Requestor ID");

                            LEmployee.Init;
                            if LEmployee.Get(LUser."Employee No.") then
                                LFullName := LEmployee.FullName;

                            CRLF := '';
                            CRLF[1] := 13;
                            CRLF[2] := 10;

                            if LSMTPMailSetup.Get then begin
                                if LUser2."E-Mail" <> '' then begin
                                    LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                            'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                                    LSMTPMail.AppendBody(' has approved your PO.  The PO is being prepared to be sent for MD approval');
                                    LSMTPMail.AppendBody(CRLF + CRLF);
                                    LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                                    LSMTPMail.AppendBody(CRLF);
                                    LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                                    LSMTPMail.Send;
                                end;
                            end;
                        end;

                        //END Mails
                    end
                end else
                    if "Document Subtype" <> "document subtype"::CAPEX then begin
                        if "RMT Total Amount Inc. VAT" <= PurchasesPayablesSetup."Opex Amount" then begin
                            Status := Status::Released;
                            "HOD Finance" := UserId;
                            "HOD Finance App Date" := Today;
                            Modify;
                            Message('Approval Successful');
                        end else begin
                            Status := Status::"Pending MD approval";
                            "HOD Finance" := UserId;
                            "HOD Finance App Date" := Today;
                            Modify;
                            Message('Approval Successful');

                            //sending email notification
                            if HRSetup."Enable Travel Notifications" then begin
                                LUser.Get(UserId);
                                LUser2.Get("Requestor ID");

                                LEmployee.Init;
                                if LEmployee.Get(LUser."Employee No.") then
                                    LFullName := LEmployee.FullName;

                                CRLF := '';
                                CRLF[1] := 13;
                                CRLF[2] := 10;

                                if LSMTPMailSetup.Get then begin
                                    if LUser2."E-Mail" <> '' then begin
                                        LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                                'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                                        LSMTPMail.AppendBody(' has approved your PO.  The PO is being prepared to be sent for MD approval');
                                        LSMTPMail.AppendBody(CRLF + CRLF);
                                        LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                                        LSMTPMail.AppendBody(CRLF);
                                        LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                                        LSMTPMail.Send;
                                    end;
                                end;
                            end;

                            //END Mails

                        end
                    end
            end else
                if "Document Type" = "document type"::UnBudgeted then begin
                    if "Document Subtype" = "document subtype"::CAPEX then begin
                        if "RMT Total Amount Inc. VAT" <= PurchasesPayablesSetup."Unbudgeted Opex Amount" then begin
                            Status := Status::Released;
                            "HOD Finance" := UserId;
                            "HOD Finance App Date" := Today;
                            Modify;
                            Message('Approval Successful');

                        end else begin
                            Status := Status::"Pending MD approval";
                            "HOD Finance" := UserId;
                            "HOD Finance App Date" := Today;
                            Modify;
                            Message('Approval Successful');
                            //sending email notification
                            if HRSetup."Enable Travel Notifications" then begin
                                LUser.Get(UserId);
                                LUser2.Get("Requestor ID");

                                LEmployee.Init;
                                if LEmployee.Get(LUser."Employee No.") then
                                    LFullName := LEmployee.FullName;

                                CRLF := '';
                                CRLF[1] := 13;
                                CRLF[2] := 10;

                                if LSMTPMailSetup.Get then begin
                                    if LUser2."E-Mail" <> '' then begin
                                        LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                                'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                                        LSMTPMail.AppendBody(' has approved your PO.  The PO is being prepared to be sent for MD approval');
                                        LSMTPMail.AppendBody(CRLF + CRLF);
                                        LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                                        LSMTPMail.AppendBody(CRLF);
                                        LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                                        LSMTPMail.Send;
                                    end;
                                end;
                            end;

                            //END Mails

                        end
                    end else
                        if "Document Subtype" <> "document subtype"::CAPEX then begin
                            if "RMT Total Amount Inc. VAT" <= PurchasesPayablesSetup."UnbudSgeted Capex Amount" then begin
                                Status := Status::Released;
                                "HOD Finance" := UserId;
                                "HOD Finance App Date" := Today;
                                Modify;
                                Message('Approval Successful');
                            end else begin
                                Status := Status::"Pending MD approval";
                                "HOD Finance" := UserId;
                                "HOD Finance App Date" := Today;
                                Modify;
                                Message('Approval Successful');
                                //sending email notification
                                if HRSetup."Enable Travel Notifications" then begin
                                    LUser.Get(UserId);
                                    LUser2.Get("Requestor ID");

                                    LEmployee.Init;
                                    if LEmployee.Get(LUser."Employee No.") then
                                        LFullName := LEmployee.FullName;

                                    CRLF := '';
                                    CRLF[1] := 13;
                                    CRLF[2] := 10;

                                    if LSMTPMailSetup.Get then begin
                                        if LUser2."E-Mail" <> '' then begin
                                            LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                                    'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                                            LSMTPMail.AppendBody(' has approved your PO.  The PO is being prepared to be sent for MD approval');
                                            LSMTPMail.AppendBody(CRLF + CRLF);
                                            LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                                            LSMTPMail.AppendBody(CRLF);
                                            LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                                            LSMTPMail.Send;
                                        end;
                                    end;
                                end;

                                //END Mails
                            end
                        end
                end


            //END BKR


        end;
    end;

    procedure PRMDApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        BPRHeader: Record UnknownRecord51131;
        BPRLines: Record UnknownRecord51132;
        PurchaseRHeader: Record UnknownRecord51100;
        PurchaseRLines: Record UnknownRecord51101;
        BudgetSetup: Record UnknownRecord51126;
        FASetup: Record "FA Posting Group";
        FixedAsset: Record "Fixed Asset";
        Item: Record Item;
        ItemSetup: Record "Inventory Posting Setup";
    begin
        with PRHeader do begin
            HRSetup.Get;

            if Status <> Status::"Pending MD approval" then
                Error('Only pending PR can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        //LSMTPMail.AddCC('info@ujuzitech.com');
                        LSMTPMail.AppendBody(' has approved your PR.  The PR has been sent to MD for processing');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            //END Mails
            //BKR 30.01.2020

            BudgetSetup.Get;

            PeriodSetup.Reset;
            PeriodSetup.SetRange("Active Budget", BudgetSetup."Active Budget");
            if PeriodSetup.FindFirst then
                case PeriodSetup.Period of
                    PeriodSetup.Period::Qtr1:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr1;
                    PeriodSetup.Period::Qtr2:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr2;

                    PeriodSetup.Period::Qtr3:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr3;

                    PeriodSetup.Period::Qtr4:
                        if (Today > PeriodSetup."Start Date") and (Today < PeriodSetup."End Date") then
                            CurrentPeriod := PeriodSetup.Period::Qtr4;
                end;

            PurchaseRLines.Reset;
            PurchaseRLines.SetRange("Document No.", "No.");

            //PurchaseRLines.SETFILTER("Activity Code",'%1',PurchaseRLines."Activity Code");
            if PurchaseRLines.FindFirst then begin

                repeat
                    if (PurchaseRLines."Budgeted Line" = true) or (PurchaseRLines."Activity Code" <> '') then begin
                        //If type G/L Account
                        if PurchaseRLines.Type = PurchaseRLines.Type::"G/L Account" then begin
                            BPRHeader.Reset;
                            BPRHeader.SetRange("Budget Name", BudgetSetup."Active Budget");
                            BPRHeader.SetRange("Shortcut Dimension 2 Code", PurchaseRLines."Shortcut Dimension 2 Code");
                            BPRHeader.SetRange(Status, BPRHeader.Status::Approved);
                            if BPRHeader.FindFirst then begin

                                BPRLines.Reset;
                                BPRLines.SetRange("Budget Name", BudgetSetup."Active Budget");
                                BPRLines.SetRange("Global Dimension 2 Code", BPRHeader."Shortcut Dimension 2 Code");
                                BPRLines.SetRange("G/L Account No.", PurchaseRLines."No.");
                                BPRLines.SetRange(Period, CurrentPeriod);
                                BPRLines.SetRange("Activity Code", PurchaseRLines."Activity Code");
                                //ERROR(FORMAT(BPRLines."Budget Name"));
                                if BPRLines.FindFirst then begin
                                    repeat
                                        BPRLines."Consumed Amount" := BPRLines."Consumed Amount" + PurchaseRLines."Line Amount";
                                        BPRLines.Modify;
                                    until BPRHeader.Next = 0;
                                end
                            end
                        end
                        //If type item
                        else
                            if PurchaseRLines.Type = PurchaseRLines.Type::Item then begin

                                Item.Reset;
                                Item.SetRange(Item."No.", PurchaseRLines."No.");
                                if Item.FindFirst then
                                    if Item."Inventory Posting Group" <> '' then begin
                                        ItemSetup.SetRange("Invt. Posting Group Code", Item."Inventory Posting Group");
                                        ItemSetup.SetRange("Location Code", PurchaseRLines."Location Code");
                                        if ItemSetup.FindFirst then
                                            if
                  ItemSetup."Inventory Account" <> '' then begin
                                                BPRHeader.Reset;
                                                BPRHeader.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                BPRHeader.SetRange("Shortcut Dimension 2 Code", PurchaseRLines."Shortcut Dimension 2 Code");
                                                BPRHeader.SetRange(Status, BPRHeader.Status::Approved);
                                                if BPRHeader.FindFirst then begin

                                                    BPRLines.Reset;
                                                    BPRLines.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                    BPRLines.SetRange("Global Dimension 2 Code", BPRHeader."Shortcut Dimension 2 Code");
                                                    BPRLines.SetRange(Period, CurrentPeriod);
                                                    BPRLines.SetRange("Activity Code", PurchaseRLines."Activity Code");
                                                    BPRLines.SetRange("G/L Account No.", ItemSetup."Inventory Account");
                                                    if BPRLines.FindFirst then begin
                                                        begin
                                                            repeat
                                                                BPRLines."Consumed Amount" := BPRLines."Consumed Amount" + PurchaseRLines."Line Amount";
                                                                BPRLines.Modify;
                                                            until BPRLines.Next = 0;
                                                        end
                                                    end
                                                end
                                            end

                                    end
                                    //If type Fixed Asset
                                    else
                                        if PurchaseRLines.Type = PurchaseRLines.Type::"Fixed Asset" then begin
                                            FixedAsset.Reset;
                                            FixedAsset.SetRange(FixedAsset."No.", PurchaseRLines."No.");
                                            if FixedAsset.FindFirst then
                                                if FixedAsset."FA Posting Group" <> '' then begin
                                                    FASetup.SetRange(Code, FixedAsset."FA Posting Group");
                                                    if FASetup.FindFirst then
                                                        if
                                FASetup."Acquisition Cost Account" <> '' then begin
                                                            BPRHeader.Reset;
                                                            BPRHeader.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                            BPRHeader.SetRange("Shortcut Dimension 2 Code", PurchaseRLines."Shortcut Dimension 2 Code");
                                                            BPRHeader.SetRange(Status, BPRHeader.Status::Approved);
                                                            if BPRHeader.FindFirst then begin

                                                                BPRLines.Reset;
                                                                BPRLines.SetRange("Budget Name", BudgetSetup."Active Budget");
                                                                BPRLines.SetRange("Global Dimension 2 Code", BPRHeader."Shortcut Dimension 2 Code");
                                                                BPRLines.SetRange(Period, CurrentPeriod);
                                                                BPRLines.SetRange("Activity Code", PurchaseRLines."Activity Code");
                                                                BPRLines.SetRange("G/L Account No.", FASetup."Acquisition Cost Account");
                                                                if BPRLines.FindFirst then begin
                                                                    repeat
                                                                        BPRLines."Consumed Amount" := BPRLines."Consumed Amount" + PurchaseRLines."Line Amount";
                                                                        BPRLines.Modify;
                                                                    until BPRLines.Next = 0;
                                                                end
                                                            end
                                                        end
                                                end
                                        end;

                                PurchaseRLines."Budgeted Line" := true;
                                PurchaseRLines.Modify;
                                //end of PurchaseRLines."Budgeted Line";
                            end
                    end
                until PurchaseRLines.Next = 0;
            end;
            //BKR END

            //BKR 25/03/2020

            Status := Status::Released;
            "MD Approval" := UserId;
            "MD App Date" := Today;
            Modify;
            Message('Approval Successful');



            //END BKR


        end;
    end;

    procedure PRFinanceApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PRHeader do begin
            HRSetup.Get;
            if ("Shortcut Dimension 1 Code" <> '500') then begin
                if (Status <> Status::"Pending Finance Approval") then
                    Error('Only pending PR can be approved');

                //sending email notification
                if HRSetup."Enable Travel Notifications" then begin
                    LUser.Get(UserId);
                    LUser2.Get("Requestor ID");

                    LEmployee.Init;
                    if LEmployee.Get(LUser."Employee No.") then
                        LFullName := LEmployee.FullName;

                    CRLF := '';
                    CRLF[1] := 13;
                    CRLF[2] := 10;

                    if LSMTPMailSetup.Get then begin
                        if LUser2."E-Mail" <> '' then begin
                            LSMTPMail.CreateMessage('Purchase Requisition Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                    'PR Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                            LSMTPMail.AppendBody(' has approved your PR.  The PR is has been sent to Head of Finance for Approval');
                            LSMTPMail.AppendBody(CRLF + CRLF);
                            LSMTPMail.AppendBody('PR DETAILS' + CRLF);
                            LSMTPMail.AppendBody(CRLF);
                            LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);
                            LSMTPMail.Send;
                        end;
                    end;
                end;


                Status := Status::"Pending HOD Finance";
                "Finance Approval" := UserId;
                "Finance App Date" := Today;
                Modify;


                Message('Approval Successful');
            end else begin

                if (Status <> Status::"Pending Finance Approval") then
                    Error('Only pending PR can be approved');

                //sending email notification
                if HRSetup."Enable Travel Notifications" then begin
                    LUser.Get(UserId);
                    LUser2.Get("Requestor ID");

                    LEmployee.Init;
                    if LEmployee.Get(LUser."Employee No.") then
                        LFullName := LEmployee.FullName;

                    CRLF := '';
                    CRLF[1] := 13;
                    CRLF[2] := 10;

                    if LSMTPMailSetup.Get then begin
                        if LUser2."E-Mail" <> '' then begin
                            LSMTPMail.CreateMessage('Purchase Requisition Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                    'PR Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                            LSMTPMail.AppendBody(' has approved your PR.  The PR is has been sent to Head of Finance for Approval');
                            LSMTPMail.AppendBody(CRLF + CRLF);
                            LSMTPMail.AppendBody('PR DETAILS' + CRLF);
                            LSMTPMail.AppendBody(CRLF);
                            LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);
                            LSMTPMail.Send;
                        end;
                    end;
                end;


                Status := Status::Released;
                "Finance Approval" := UserId;
                "Finance App Date" := Today;
                Modify;


                Message('Approval Successful');

            end
        end;
    end;

    procedure SubmitPRForApproval(var ReqHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with ReqHeader do begin
            HRSetup.Get;

            if "Line Manager" = '' then
                Error('Please select the approver for this requisition');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin

                LUser.Get(UserId);
                LUser2.Get("Line Manager");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Purchase Requisition Approval Request -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has submitted a Purchase Requisition request that requires your approval.  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PURCHASE REQUISITION REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::"Pending Line Managerl";
            "Submit Date" := Today;
            Modify;
            Message('Approval submitted successfully');

        end;
    end;

    procedure PRTechApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with PRHeader do begin
            HRSetup.Get;

            if Status <> Status::"Pending Technical Approval" then
                Error('Only pending PR can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your PR.  The PR has been sent to Head of Finance for Approval');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::"Pending Finance Approval";
            "Technical Approval" := UserId;
            "Technical App Date" := Today;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure DisapprovePRApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PRHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PR request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::Dissaproved;
            "Line Approval" := UserId;
            "Line Mgr App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure DisapprovePRFinanceApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PRHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PR request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::Dissaproved;
            "Finance Approval" := UserId;
            "Finance App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure DisapprovePRTechApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PRHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PR request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::Dissaproved;
            "Technical Approval" := UserId;
            "Technical App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure DisapprovePRHODApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PRHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PR request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::Dissaproved;
            "HOD Approval" := UserId;
            "HOD App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure DisapprovePRMDApproval(var PRHeader: Record UnknownRecord51100)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PRHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Requestor ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PR Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PR request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PR  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PR No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::Dissaproved;
            "MD Approval" := UserId;
            "MD App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;
 */
    /*     procedure SubmitSRForApproval(var ReqHeader: Record "Transfer Header")
        var
            LSMTPMailSetup: Record "SMTP Mail Setup";
            LUser: Record "User Setup";
            LUser2: Record "User Setup";
            LSMTPMail: Codeunit "SMTP Mail";
            CRLF: Text[30];
            LFullName: Text[120];
            LEmployee: Record Employee;
        begin
            with ReqHeader do begin
                HRSetup.Get;

                if "Line Manager" = '' then
                    Error('Please select the approver for this requisition');

                //sending email notification
                if HRSetup."Enable Travel Notifications" then begin

                    LUser.Get(UserId);
                    LUser2.Get("Line Manager");

                    LEmployee.Init;
                    if LEmployee.Get(LUser."Employee No.") then
                        LFullName := LEmployee.FullName;

                    CRLF := '';
                    CRLF[1] := 13;
                    CRLF[2] := 10;

                    if LSMTPMailSetup.Get then begin
                        if LUser2."E-Mail" <> '' then begin
                            LSMTPMail.CreateMessage('Stores Requisition Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                    'Stores Requisition Approval Request -> ' + "No." + '-' + LFullName, LFullName, false);
                            LSMTPMail.AppendBody(' has submitted a Stores Requisition request that requires your approval.  ');
                            LSMTPMail.AppendBody(CRLF + CRLF);
                            LSMTPMail.AppendBody('STORES REQUISITION REQUEST DETAILS' + CRLF);
                            LSMTPMail.AppendBody(CRLF);
                            LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                            LSMTPMail.Send;
                        end;
                    end;
                end;

                Status := Status::"Pending Approval";
                "Submit Date" := Today;
                Modify;
                Message('Approval submitted successfully');

            end;
        end; */

    /* procedure ApproveSRApproval(var PRHeader: Record "Transfer Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with PRHeader do begin
            HRSetup.Get;

            if Status <> Status::"Pending Approval" then
                Error('Only pending SR can be approved');

            UserSetup.SetRange("Stores Officer", true);
            if UserSetup.FindFirst then
                StoresOfficerEmail := UserSetup."E-Mail";



            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("User ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stores Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'SR Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your SR.  The SR has been sent to Stores for processing');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AddCC(StoresOfficerEmail);
                        LSMTPMail.AppendBody('SR DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('SR No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;


            Status := Status::Released;
            "Line Approval" := UserId;
            "Line APP SR date" := Today;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure DisapproveSRApproval(var PRHeader: Record "Transfer Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PRHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this SR request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("User ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stores Requisition  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'SR Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your SR request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('SR  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('SR No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::Dissaproved;
            "Line Approval" := UserId;
            "Line APP SR date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;
 */
    /* procedure ApprovePCApproval(var PCHeader: Record UnknownRecord50052)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with PCHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending Approval" then
                Error('Only pending PC can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Petty Cash Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PC Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your PC.  The PC is being prepared to be sent for finance approval');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PC DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PC No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::"Pending Finance";
            "Line Manager Approval" := UserId;
            // "Approval Date" := TODAY;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure PCFinanceApproval(var PCHeader: Record UnknownRecord50052)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with PCHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending Finance" then
                Error('Only pending PC can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Petty Cash Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PC Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your PC.  The PC is being prepared to be sent for HOD  finance approval');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PC DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PC No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::"Pending HOD Finance";
            "Finance Approval" := UserId;
            // "Approval Date" := TODAY;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure DisapprovePCApproval(var PCHeader: Record UnknownRecord50052)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PCHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PC request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Petty Cash  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PC Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PC request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PC  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PC No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Disapproved;
            "Line Manager Approval" := UserId;
            //"Approval Date" := TODAY;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure PCHODFinanceApproval(var PCHeader: Record UnknownRecord50052)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with PCHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending HOD Finance" then
                Error('Only pending PC can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Petty Cash Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PC Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your PC. ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PC DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PC No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Approved;
            "HOD Finance Approval" := UserId;
            // "Approval Date" := TODAY;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure DisapprovePCFinanceApproval(var PCHeader: Record UnknownRecord50052)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PCHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PC request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Petty Cash  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PC Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PC request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PC  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PC No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Disapproved;
            "Finance Approval" := UserId;
            //"Approval Date" := TODAY;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure DisapprovePCHODFinanceApproval(var PCHeader: Record UnknownRecord50052)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin

        with PCHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PC request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Petty Cash  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PC Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PC request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PC  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PC No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Disapproved;
            "HOD Finance Approval" := UserId;
            //"Approval Date" := TODAY;
            Modify;
            Message('Disapproval successful');

        end;
    end; */

    procedure SubmitBusinesscardForApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if Approver = '' then
                Error('Please select the line approver for this requisition');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin

                LUser.Get(UserId);
                LUser2.Get(Approver);

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Business Cards  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Business Cards Requisition Approval Request -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has submitted a business card request that requires your approval.  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('BUSINESS CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        //LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //    LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //  LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::"Pending Approval";
            "Submit Date" := Today;
            Modify;
            Message('Approval submitted successfully');

        end;
    end;

    procedure ApproveBusinessCardApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending Approval" then
                Error('Only pending Business cards requests can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Business Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Business Card Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your Business Card request.  The request is being prepared to be sent for final approval  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('BUSINESS CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        // LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //    LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Approved;
            "Approval By" := UserId;
            "Approval Date" := Today;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure DisapproveBusinessCardApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Remarks" = '' then
                Error('Please insert disapproval remarks for this business card request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Business Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Business Card Request Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your business card request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('BUSINESS CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        //LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approval Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Disapproved;
            "Approval By" := UserId;
            "Approval Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    /* procedure POMDApproval(var POHeader: Record "Purchase Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with POHeader do begin
            HRSetup.Get;

            if Status <> Status::"Pending MD Approval" then
                Error('Only pending PO can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Created By USER ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('PO Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PO Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your PO.  The PO is now ready  to be sent to the supplier');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PO DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);
                        LSMTPMail.Send;
                    end;
                end;
            end;


            Status := Status::Released;
            "MD Approver" := UserId;
            "MD App Date" := Today;
            Modify;
            Message('Approval Successful');



        end;
    end;

    procedure DisapproveMDApproval(var POHeader: Record "Purchase Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with POHeader do begin
            HRSetup.Get;

            if "Approver Remarks" = '' then
                Error('Please insert disapproval remarks for this PO request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Created By USER ID");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Purchase Order  Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'PO Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your PO request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('PO  REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('PO No. :   ' + "No." + CRLF);

                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approver Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            Status := Status::Dissaproved;
            "MD Approver" := UserId;
            "MD App Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;
 */
    procedure SubmitStampforapproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if Approver = '' then
                Error('Please select the line approver for this requisition');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin

                LUser.Get(UserId);
                LUser2.Get(Approver);

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stamp Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Stamp Cards Requisition Approval Request -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has submitted a stamp card request that requires your approval.  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('STAMP REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        //LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //    LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //  LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::"Pending Approval";
            "Submit Date" := Today;
            Modify;
            Message('Approval submitted successfully');

        end;
    end;

    procedure SubmitStampHODApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending Approval" then
                Error('Only pending Stamp cards requests can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stamp Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Stamp Card Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your Business Card request.  The request is being prepared to be sent for final approval  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('STAMP CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        // LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //    LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::"Pending Approval";
            "Proc Manager Approval" := UserId;
            "Proc Manager Approval Date" := Today;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure ApprovalofStamp(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending Approval" then
                Error('Only pending Stamp cards requests can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stamp Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Stamp Card Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your Business Card request.  The request is being prepared to be sent for final approval  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('STAMP CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        // LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //    LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::"Pending HOD";
            "Approval By" := UserId;
            "Approval Date" := Today;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure HODStampApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Status" <> "approval status"::"Pending HOD" then
                Error('Only pending Stamp cards requests can be approved');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;

                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stamp Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Stamp Card Request Approved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has approved your Business Card request.  The request is being prepared to be sent for final approval  ');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('STAMP CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        // LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //    LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Approved;
            "Proc Manager Approval" := UserId;
            "Proc Manager Approval Date" := Today;
            Modify;
            Message('Approval Successful');

        end;
    end;

    procedure DisapproveStampApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Remarks" = '' then
                Error('Please insert disapproval remarks for this stamp card request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stamp Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Stamp Card Request Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your business card request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('STAMP CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        //LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approval Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Disapproved;
            "Approval By" := UserId;
            "Approval Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    procedure HODDisapproveStampApproval(var TravelReqHeader: Record "Travel Request Header")
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with TravelReqHeader do begin
            HRSetup.Get;

            if "Approval Remarks" = '' then
                Error('Please insert disapproval remarks for this stamp card request.  It cannot be blank.');

            //sending email notification
            if HRSetup."Enable Travel Notifications" then begin
                LUser.Get(UserId);
                LUser2.Get("Raised By");

                LEmployee.Init;
                if LEmployee.Get(LUser."Employee No.") then
                    LFullName := LEmployee.FullName;

                CRLF := '';
                CRLF[1] := 13;
                CRLF[2] := 10;

                if LSMTPMailSetup.Get then begin
                    if LUser2."E-Mail" <> '' then begin
                        LSMTPMail.CreateMessage('Stamp Card Management', 'erpNotifications@gab.co.ke', LUser2."E-Mail",
                                                'Stamp Card Request Disapproved -> ' + "No." + '-' + LFullName, LFullName, false);
                        LSMTPMail.AppendBody(' has disapproved your business card request.');
                        LSMTPMail.AppendBody(CRLF + CRLF);
                        LSMTPMail.AppendBody('STAMP CARD REQUEST DETAILS' + CRLF);
                        LSMTPMail.AppendBody(CRLF);
                        LSMTPMail.AppendBody('Requisition No. :   ' + "No." + CRLF);
                        //LSMTPMail.AppendBody('Travel From - To :   ' + UPPERCASE("Travel From" + ' - ' + "Travel To" + CRLF));
                        //LSMTPMail.AppendBody('Travel Dates :   ' + UPPERCASE(FORMAT("Travel From Date") + ' - ' + FORMAT("Travel To Date") + CRLF));
                        //LSMTPMail.AppendBody('Travel Purpose :   ' + UPPERCASE("Travel Purpose" + CRLF));
                        LSMTPMail.AppendBody('Approver Remarks :   ' + UpperCase("Approval Remarks" + CRLF));
                        LSMTPMail.Send;
                    end;
                end;
            end;

            "Approval Status" := "approval status"::Disapproved;
            "Proc Manager Approval" := UserId;
            "Proc Manager Approval Date" := Today;
            Modify;
            Message('Disapproval successful');

        end;
    end;

    local procedure "*****************UTL Asset Transfer********************"()
    begin
    end;

    /* procedure ApproveAssetTransApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        FALocation: Record "FA Location";
        FAsset: Record "Fixed Asset";
        AssetLines: Record UnknownRecord50014;
    begin
        with AssetTransHeader do begin
            if "Shipping Line Manager" <> UserId then
                Error('You are not approver for this document');

            if Status <> Status::"Pending Line Manager" then begin
                Error('Only pending Asset Transfer can be approved');
            end else
                if "Shipping Line Manager" <> UserId then begin
                    Error('You are not the current approver for this document');
                end else begin
                    if Confirm('Approve This Request?', false) = true then begin
                        //Transfer to In-transit Location
                        AssetLines.Reset;
                        AssetLines.SetRange("Document No.", "Document No.");
                        if AssetLines.FindFirst then begin
                            repeat
                                FAsset.Reset;
                                FAsset.Get(AssetLines."No.");
                                FAsset."FA Location Code" := "In-Transit Code";
                                FAsset.Modify;
                            until AssetLines.Next = 0;
                        end;
                        //End
                        Status := Status::Released;
                        //"Shipping Approval  Status" := "Shipping Approval  Status"::"Pending Receiving Manager";
                        "Shipping Approval  Status" := "shipping approval  status"::"Shipped-Pending  Receipt";
                        "Ship. Line Mgr App Date" := Today;
                        Modify;

                        Message('Approval Request Has been Approved Successfully.');

                        //sending email notification
                        HRSetup.Get;
                        if HRSetup."Enable Travel Notifications" then begin
                            LUser.Get("Shipping User");
                            LUser2.Get("Shipping Line Manager");

                            LEmployee.Init;
                            if LEmployee.Get(LUser."Employee No.") then
                                LFullName := LEmployee.FullName;
                            LuserEmail := LUser2."E-Mail";
                            if LuserEmail <> '' then begin

                                // HumanResSetup.GET();
                                EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                                EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' is has been Approved.';
                                Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, false);
                                Email.Send();
                            end else begin
                                exit
                            end;
                        end;
                        //End Email Approval.
                    end;
                end;
        end;
        //END;

    end;

    procedure AssetTransDelegateApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        FALocation: Record "FA Location";
    begin
        with AssetTransHeader do begin
            if Confirm('Delegate This Request?', false) = true then begin
                if "Shipping Line Manager" <> UserId then
                    Error('You are not approver for this document');

                UserSetup.Get("Shipping User");
                if Status <> Status::"Pending Line Manager" then begin
                    Error('Only pending Asset Transfer can be Delegated');
                end else begin
                    "Shipping Line Manager" := UserSetup.Substitute;
                    Modify;
                    Message('Approval Has been Delegated Successfully');

                    if UserSetup.Substitute <> '' then begin
                        //sending email notification
                        HRSetup.Get;
                        if HRSetup."Enable Travel Notifications" then begin
                            LUser.Get("Shipping User");
                            LUser2.Get(UserSetup.Substitute);

                            LEmployee.Init;
                            if LEmployee.Get(LUser."Employee No.") then
                                LFullName := LEmployee.FullName;
                            LuserEmail := LUser2."E-Mail";

                            if LuserEmail <> '' then begin

                                EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                                EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' is awaiting your approval.';
                                Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, false);
                                Email.Send();
                            end else begin
                                exit
                            end;
                        end;
                    end;
                    //End Email Approval.
                end;
            end;
        end;
    end;

    procedure AssetTransRejectApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        FALocation: Record "FA Location";
    begin

        with AssetTransHeader do begin

            if "Shipping Line Manager" <> UserId then
                Error('You are not approver for this document');

            if Confirm('Reject This Request?', false) = true then begin
                if (Status <> Status::"Pending Line Manager") then begin
                    Error('Only pending Asset Transfer can be Rejected');
                end else begin
                    TestField("Shipping Line Manager", UserId);
                    TestField("Approver Remarks");
                    Status := Status::Open;
                    "Shipping Approval  Status" := "shipping approval  status"::Open;
                    "Ship. Line Mgr App Date" := Today;
                    Modify;
                end;
                //sending email notification
                HRSetup.Get;
                if HRSetup."Enable Travel Notifications" then begin
                    LUser.Get("Shipping User");
                    LUser2.Get("Shipping Line Manager");

                    LEmployee.Init;
                    if LEmployee.Get(LUser."Employee No.") then
                        LFullName := LEmployee.FullName;
                    LuserEmail := LEmployee."E-Mail";

                    if LuserEmail <> '' then begin

                        // HumanResSetup.GET();
                        EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                        EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' Has been rejected.';
                        Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
                        Email.Send();
                    end else begin
                        exit
                    end;
                end;
                //End Email Approval.

                Message('Approval Request Has Been Rejected');
            end;
        end;
    end;

    procedure SubmitAssetTransForApproval(var AssetHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with AssetHeader do begin

            if ("Shipping Line Manager" = '') or ("Receiving Line Manager" = '') then
                Error('Please select All approvers for this Asset Transfer');

            if Confirm('Send Approval Request?', false) = true then begin

                "Shipping Approval  Status" := "shipping approval  status"::"Pending Line Manager";
                Status := Status::"Pending Line Manager";
                Modify;
                // END;

                //sending email notification
                HRSetup.Get;
                if HRSetup."Enable Travel Notifications" then begin
                    LUser.Get("Shipping User");
                    LUser2.Get("Shipping Line Manager");

                    LEmployee.Init;
                    if LEmployee.Get(LUser."Employee No.") then
                        LFullName := LEmployee.FullName;
                    LuserEmail := LUser2."E-Mail";
                    if LuserEmail <> '' then begin

                        EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                        EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' is awaiting your approval.';
                        Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
                        Email.Send();
                    end else begin
                        exit
                    end;
                end;
                //End Email Approval.

                Message('Approval Request submitted successfully');
            end;
        end;
    end;

    procedure SubmitAssetReceiptForApproval(var AssetHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with AssetHeader do begin
            if "Receiving User" <> UserId then
                Error('You are not receiving user for this document');

            if ("Shipping Line Manager" = '') or ("Receiving Line Manager" = '') then
                Error('Please select All approvers for this Asset Transfer');
            if Status <> Status::Released then
                Error('Shipping Approver must approve this document');

            if Confirm('Send Approval Request?', false) = true then begin

                "Shipping Approval  Status" := "shipping approval  status"::"Pending Receiving Manager";
                Modify;
                //  END;

                //sending email notification
                HRSetup.Get;
                if HRSetup."Enable Travel Notifications" then begin
                    LUser.Get("Receiving User");
                    LUser2.Get("Receiving Line Manager");

                    LEmployee.Init;
                    if LEmployee.Get(LUser."Employee No.") then
                        LFullName := LEmployee.FullName;
                    LuserEmail := LUser2."E-Mail";
                    if LuserEmail <> '' then begin

                        EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                        EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' is awaiting your approval.';
                        Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
                        Email.Send();
                    end else begin
                        exit
                    end;
                end;
                //End Email Approval.

                Message('Approval Request submitted successfully');
            end
        end;
        //END;
    end;

    procedure AssetReceiptCancelApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with AssetTransHeader do begin
            if "Receiving User" <> UserId then
                Error('You are not Receiving user for this document');

            if "Shipping Approval  Status" <> "shipping approval  status"::"Pending Receiving Manager" then begin
                Error('Only pending Asset Transfer can be Cancelled');
            end else begin
                if Confirm('Cancel This Request?', false) = true then begin
                    Status := Status::Released;
                    "Shipping Approval  Status" := "shipping approval  status"::Open;
                    "Ship. Line Mgr App Date" := Today;
                    //   END;
                    //sending email notification
                    HRSetup.Get;
                    if HRSetup."Enable Travel Notifications" then begin
                        LUser.Get("Shipping User");
                        LUser2.Get("Shipping Line Manager");
                        Modify;

                        LEmployee.Init;
                        if LEmployee.Get(LUser."Employee No.") then
                            LFullName := LEmployee.FullName;
                        LuserEmail := LUser."E-Mail";
                        if LuserEmail <> '' then begin

                            // HumanResSetup.GET();
                            EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                            EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' Has been Cancelled.';
                            Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
                            Email.Send();
                        end else begin
                            exit
                        end;

                        //End Email Approval.
                        Message('Document has been Reopened');
                    end
                end;

            end;
        end;
    end;

    procedure AssetTransCancelApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with AssetTransHeader do begin
            if "Shipping User" <> UserId then
                Error('You are not approver for this document');

            if Status <> Status::"Pending Line Manager" then begin
                Error('Only pending Asset Transfer can be Cancelled');
            end else begin
                if Confirm('Cancel This Request?', false) = true then begin
                    Status := Status::Open;
                    "Shipping Approval  Status" := "shipping approval  status"::Open;
                    "Ship. Line Mgr App Date" := Today;
                    Modify;
                    //  END;
                    //sending email notification
                    HRSetup.Get;
                    if HRSetup."Enable Travel Notifications" then begin
                        LUser.Get("Shipping User");
                        LUser2.Get("Shipping Line Manager");
                        Modify;

                        LEmployee.Init;
                        if LEmployee.Get(LUser."Employee No.") then
                            LFullName := LEmployee.FullName;
                        LuserEmail := LUser."E-Mail";
                        if LuserEmail <> '' then begin

                            // HumanResSetup.GET();
                            EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                            EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' Has been Cancelled.';
                            Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
                            Email.Send();
                        end else begin
                            exit
                        end;

                        //End Email Approval.
                        Message('Document has been Reopened');
                    end;
                end;

            end;
        end;
    end;

    procedure ApproveReceivedAssetTransApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        FixedAsset: Record "Fixed Asset";
        FALocation: Record "FA Location";
        FAsset: Record "Fixed Asset";
        AssetLines: Record UnknownRecord50014;
    begin
        with AssetTransHeader do begin
            if "Receiving Line Manager" <> UserId then
                Error('You are not approver for this document');

            if ("Shipping Approval  Status" <> "shipping approval  status"::"Pending Receiving Manager") and (Status <> Status::Released) then begin
                Error('Only pending Asset Transfer can be approved');
            end else begin
                TestField("Receiving Line Manager", UserId);
                if Confirm('Approve This Request?', false) = true then begin
                    Status := Status::Released;
                    "Shipping Approval  Status" := "shipping approval  status"::Released;
                    "Rec. Line Mgr App Date" := Today;
                    Modify;

                    Message('Approval Has been Approved Successfully');

                    //sending email notification
                    HRSetup.Get;
                    if HRSetup."Enable Travel Notifications" then begin
                        LUser.Get("Receiving User");
                        LUser2.Get("Receiving Line Manager");

                        LEmployee.Init;
                        if LEmployee.Get(LUser."Employee No.") then
                            LFullName := LEmployee.FullName;
                        LuserEmail := LUser."E-Mail";
                        if LuserEmail <> '' then begin

                            // HumanResSetup.GET();
                            EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                            EmailMessage := 'Kindly note,' + 'Asset Transfer -' + "Document No." + ' Has been Approved.';
                            Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
                            Email.Send();
                        end else begin
                            exit
                        end;
                    end;
                    //End Email Approval.
                end;
            end
        end
        //END;

    end;

    procedure AssetTransReceivedDelegateApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
    begin
        with AssetTransHeader do begin
            if "Receiving Line Manager" <> UserId then
                Error('You are not approver for this document');

            UserSetup.Get("Receiving Line Manager");
            if (Status <> Status::Released) and ("Shipping Approval  Status" <> "shipping approval  status"::"Pending Receiving Manager") then begin
                Error('Only pending Asset Transfer can be Delegated');
            end else
                if Confirm('Delegate This Request?', false) = true then begin
                    if UserSetup.Substitute <> '' then
                        "Receiving Line Manager" := UserSetup.Substitute;
                    Modify;
                    //sending email notification
                    HRSetup.Get;
                    if HRSetup."Enable Travel Notifications" then begin
                        LUser.Get(UserSetup.Substitute);
                        LUser2.Get("Receiving Line Manager");

                        LEmployee.Init;
                        if LEmployee.Get(LUser."Employee No.") then
                            LFullName := LEmployee.FullName;
                        LuserEmail := LUser."E-Mail";
                        if LuserEmail <> '' then begin

                            EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
                            EmailMessage := 'Kindly note,' + 'Asset Transfer Receipt-' + "Document No." + ' Is awaiting your approval.';
                            Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
                            Email.Send();
                        end else begin
                            exit
                        end;
                    end;
                    //End Email Approval.}

                    Message('Approval Has been Delegated Successfully');
                end;
        end;
    end;

    procedure AssetTransReceivedRejectApproval(var AssetTransHeader: Record UnknownRecord50013)
    var
        LSMTPMailSetup: Record "SMTP Mail Setup";
        LUser: Record "User Setup";
        LUser2: Record "User Setup";
        LSMTPMail: Codeunit "SMTP Mail";
        CRLF: Text[30];
        LFullName: Text[120];
        LEmployee: Record Employee;
        FALocation: Record "FA Location";
        FAsset: Record "Fixed Asset";
        AssetLines: Record UnknownRecord50014;
    begin
        with AssetTransHeader do begin
            if "Receiving Line Manager" <> UserId then
                Error('You are not approver for this document');

            if (Status <> Status::Released) and ("Shipping Approval  Status" <> "shipping approval  status"::"Pending Receiving Manager") then begin
                Error('Only pending Asset Transfer can be Rejected');
            end else
                // TESTFIELD("Approver Remarks");
                TestField("Receiving Line Manager", UserId);
            if Confirm('Reject This Request?', false) = true then begin
                /*
                    //Transfer to Back to Location
               AssetLines.RESET;
               AssetLines.SETRANGE("Document No.","Document No.");
               IF AssetLines.FINDFIRST THEN BEGIN
                 REPEAT
                   FAsset.RESET;
                   FAsset.GET(AssetLines."No.");
                   FAsset."FA Location Code" := "Transfer From Code";
                   FAsset.MODIFY;
                   UNTIL AssetLines.NEXT = 0;
                   END;
                    "Receiving Approval Status" := "Receiving Approval Status"::Rejected;
                  "Shipping Approval  Status" := "Shipping Approval  Status"::Open;
                  "Rec. Line Mgr App Date" := TODAY;
                  Status := Status::Open;
                   MODIFY;
                   //End*/
    /* "Receiving Approval Status" := "receiving approval status"::Rejected;
    "Shipping Approval  Status" := "shipping approval  status"::Rejected;
    "Rec. Line Mgr App Date" := Today;
    Status := Status::Released;
    Modify;
    //sending email notification
    HRSetup.Get;
    if HRSetup."Enable Travel Notifications" then begin
        LUser.Get("Shipping User");
        LUser2.Get("Shipping Line Manager");

        LEmployee.Init;
        if LEmployee.Get(LUser."Employee No.") then
            LFullName := LEmployee.FullName;
        LuserEmail := LUser."E-Mail";
        if LuserEmail <> '' then begin

            EmailSubject := 'Asset Transfer-' + "Document No." + '-Approval Request';
            EmailMessage := 'Kindly note,' + 'Asset Transfer Receipt-' + "Document No." +
            'Was rejected by Receiving Line manager' + "Receiving Line Manager" + '.';
            Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail, EmailSubject, EmailMessage, true);
            Email.Send();
        end else begin
            exit
        end;
    end;
    //End Email Approval.

    Message('Approval Request Has Been Rejected');
end;
end

end;

procedure FinanceApproveAssetTransApproval(var AssetTransHeader: Record UnknownRecord50013)
var
LSMTPMailSetup: Record "SMTP Mail Setup";
LUser: Record "User Setup";
LUser2: Record "User Setup";
LSMTPMail: Codeunit "SMTP Mail";
CRLF: Text[30];
LFullName: Text[120];
LEmployee: Record Employee;
FixedAsset: Record "Fixed Asset";
FALocation: Record "FA Location";
FAsset: Record "Fixed Asset";
AssetLines: Record UnknownRecord50014;
begin
// WITH AssetTransHeader DO BEGIN
//
// IF ("Shipping Approval  Status" <> "Shipping Approval  Status"::"Pending Finance Approver") AND (Status<>Status::"Pending Finance Approval") THEN BEGIN
//    ERROR('Only pending Asset Transfer can be approved');
// END ELSE BEGIN
//     IF CONFIRM('Approve This Request?',FALSE)= TRUE THEN BEGIN
//          Status := Status::"Pending Line Manager";
//   "Shipping Approval  Status" := "Shipping Approval  Status"::"Pending Line Manager";
//   "Finance App Date" := TODAY;
//   MODIFY;
//
//
//     //sending email notification
//        HRSetup.GET;
//  IF HRSetup."Enable Travel Notifications" THEN BEGIN
//    LUser.GET("Receiving User");
//    LUser2.GET("Receiving Line Manager");
//
//    LEmployee.INIT;
//    IF LEmployee.GET(LUser."Employee No.") THEN
//      LFullName := LEmployee.FullName;
//      LuserEmail := LUser."E-Mail";
//          IF LuserEmail <> '' THEN BEGIN
//
// // HumanResSetup.GET();
//  EmailSubject := 'Asset Transfer-'+"Document No."+'-Approval Request';
//  EmailMessage := 'Kindly note,'+'Asset Transfer -'+"Document No."+' Has been Approved.';
//  Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail,EmailSubject, EmailMessage,TRUE);
//  Email.Send();
//  END ELSE BEGIN EXIT END;
//     END;
//
// //End Email Approval.}
//  MESSAGE('Approval Request Has been Approved Successfully');
//    END;
//
//    END
//   END
// //END;
//
end;

procedure FinanceAssetTransDelegateApproval(var AssetTransHeader: Record UnknownRecord50013)
var
LSMTPMailSetup: Record "SMTP Mail Setup";
LUser: Record "User Setup";
LUser2: Record "User Setup";
LSMTPMail: Codeunit "SMTP Mail";
CRLF: Text[30];
LFullName: Text[120];
LEmployee: Record Employee;
begin
// WITH AssetTransHeader DO BEGIN
//  UserSetup.GET("Finance Approver");
//  IF (Status <>Status::"Pending Finance Approval") AND ("Shipping Approval  Status"<> "Shipping Approval  Status"::"Pending Finance Approver") THEN BEGIN
//    ERROR('Only pending Asset Transfer can be Delegated');
//    END ELSE IF UserSetup."Finance Approver" =FALSE THEN BEGIN
//      ERROR('You have not been setup as finance approver');
//    END ELSE
//      IF CONFIRM('Delegate This Request?',FALSE)= TRUE THEN BEGIN
//         "Finance Approver" := UserSetup.Substitute;
//  MODIFY;
//       //sending email notification
//             HRSetup.GET;
//  IF HRSetup."Enable Travel Notifications" THEN BEGIN
//    LUser.GET(UserSetup.Substitute);
//    LUser2.GET("Receiving Line Manager");
//
//    LEmployee.INIT;
//    IF LEmployee.GET(LUser."Employee No.") THEN
//      LFullName := LEmployee.FullName;
//      LuserEmail := LUser."E-Mail";
//          IF LuserEmail <> '' THEN BEGIN
//
//  EmailSubject := 'Asset Transfer-'+"Document No."+'-Approval Request';
//  EmailMessage := 'Kindly note,'+'Asset Transfer Receipt-'+"Document No."+' Is awaiting your approval.';
//  Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail,EmailSubject, EmailMessage,TRUE);
//  Email.Send();
//  END ELSE BEGIN EXIT END;
//     END;
// //End Email Approval.}
//
//  MESSAGE('Approval Has been Delegated Successfully');
//  END;
// END;
end;

procedure FinanceAssetTransRejectApproval(var AssetTransHeader: Record UnknownRecord50013)
var
LSMTPMailSetup: Record "SMTP Mail Setup";
LUser: Record "User Setup";
LUser2: Record "User Setup";
LSMTPMail: Codeunit "SMTP Mail";
CRLF: Text[30];
LFullName: Text[120];
LEmployee: Record Employee;
FALocation: Record "FA Location";
FAsset: Record "Fixed Asset";
AssetLines: Record UnknownRecord50014;
begin
// WITH AssetTransHeader DO BEGIN
//
//  IF (Status <>Status::"Pending Finance Approval") AND ("Shipping Approval  Status" <> "Shipping Approval  Status"::"Pending Finance Approver") THEN BEGIN
//    ERROR('Only pending Asset Transfer can be Rejected');
//    END ELSE
//    TESTFIELD("Approver Remarks");
//  IF CONFIRM('Reject This Request?',FALSE)= TRUE THEN BEGIN
//
//
//      //  "Receiving Approval Status" := "Receiving Approval Status"::Rejected;
//      "Shipping Approval  Status" := "Shipping Approval  Status"::Open;
//      "Finance App Date" := TODAY;
//      Status := Status::Open;
//       MODIFY;
//       //End
//                 //sending email notification
//                       HRSetup.GET;
//  IF HRSetup."Enable Travel Notifications" THEN BEGIN
//    LUser.GET("Shipping User");
//    LUser2.GET("Shipping Line Manager");
//
//    LEmployee.INIT;
//    IF LEmployee.GET(LUser."Employee No.") THEN
//      LFullName := LEmployee.FullName;
//      LuserEmail := LUser."E-Mail";
//          IF LuserEmail <> '' THEN BEGIN
//
//  EmailSubject := 'Asset Transfer-'+"Document No."+'-Approval Request';
//  EmailMessage := 'Kindly note,'+'Asset Transfer Receipt-'+"Document No."+    //erpNotifications@gab.co.ke
//  'Was rejected by Receiving Line manager'+ "Receiving Line Manager"+'.';
//  Email.CreateMessage(LFullName, 'erpNotifications@gab.co.ke', LuserEmail,EmailSubject, EmailMessage,TRUE);
//  Email.Send();
//  END ELSE BEGIN EXIT END;
//     END;
// //End Email Approval.}
//
//  MESSAGE('Approval Request Has Been Rejected');
//  END;
// END
end;

local procedure "**************UTL Contract Management************"()
begin
end;

procedure SubmitContractForApproval(var ContractHeader: Record UnknownRecord50075)
var
LSMTPMailSetup: Record "SMTP Mail Setup";
LUser: Record "User Setup";
LUser2: Record "User Setup";
LSMTPMail: Codeunit "SMTP Mail";
CRLF: Text[30];
LFullName: Text[120];
LEmployee: Record Employee;
begin
with ContractHeader do begin
ContractMatrix.SetRange(ContractMatrix."Approval Type", ContractMatrix."approval type"::Creation);
ContractMatrix.SetRange("User ID", "User ID");
if ContractMatrix.FindFirst then begin
    // ContractMatrix.GET("User ID");
    if ("Approval Status" = "approval status"::Open) and ("Locked Status" = "locked status"::Unlocked) and ("Termination Status" = "termination status"::Active) then begin
        "Approval Status" := "approval status"::"Pending approval";
        "Approval Type" := "approval type"::"1st Approval";
        "Current Approver" := ContractMatrix."1st Approver ID";
        "Approval Category" := "approval category"::"Create & Terminate";
        Modify;
        Message('Document No. ' + "Contract No." + 'has been sent for approval.');
    end;
end else
    Error('No approval workflow as been set for this user');
end;
end;

procedure CancelContractApprovalRequest(var ContractHeader: Record UnknownRecord50075)
var
LSMTPMailSetup: Record "SMTP Mail Setup";
LUser: Record "User Setup";
LUser2: Record "User Setup";
LSMTPMail: Codeunit "SMTP Mail";
CRLF: Text[30];
LFullName: Text[120];
LEmployee: Record Employee;
begin
with ContractHeader do begin
if ("Approval Status" = "approval status"::"Pending approval") and ("Locked Status" = "locked status"::Unlocked) and ("Termination Status" = "termination status"::Active) then begin
    "Approval Status" := "approval status"::Open;
    "Approval Type" := "approval type"::None;
    "Current Approver" := '';
    "Approval Category" := "approval category"::" ";
    Modify;
    Message('Approval Request for Document No. ' + "Contract No." + 'has been Canceled.');
end;
end;
end;

procedure ApproveContractApprovalRequest(var ContractHeader: Record UnknownRecord50075)
var
LSMTPMailSetup: Record "SMTP Mail Setup";
LUser: Record "User Setup";
LUser2: Record "User Setup";
LSMTPMail: Codeunit "SMTP Mail";
CRLF: Text[30];
LFullName: Text[120];
LEmployee: Record Employee;
FALocation: Record "FA Location";
FAsset: Record "Fixed Asset";
AssetLines: Record UnknownRecord50014;
begin
with ContractHeader do begin
ContractMatrix.SetRange("User ID", "User ID");
ContractMatrix.SetRange(ContractMatrix."Approval Type", ContractMatrix."approval type"::Creation);
if ContractMatrix.FindFirst then begin
    //ContractMatrix.GET("User ID");
    if "Approval Status" <> "approval status"::"Pending approval" then begin
        Error('Only pending Documents can be Approved');
    end else begin
        if Confirm('Approve this request?', false) = true then
            if ("Locked Status" = "locked status"::Unlocked) and ("Termination Status" = "termination status"::Active) then
                if "Approval Type" = "approval type"::"1st Approval" then begin
                    if "Current Approver" = UserId then begin
                        "Approval Status" := "approval status"::"Pending approval";
                        "Approval Type" := "approval type"::"2nd Approval";
                        "Current Approver" := ContractMatrix."2nd Approver";
                        Modify;
                        Message('Approval Request for Document No. ' + "Contract No." + ' sent for further approval.');

                    end else
                        Error('You have not been set as 1st approver');
                end else
                    if "Approval Type" = "approval type"::"2nd Approval" then begin
                        if "Current Approver" = UserId then begin
                            "Approval Status" := "approval status"::"Pending approval";
                            "Approval Type" := "approval type"::"3rd Approval";
                            "Current Approver" := ContractMatrix."3rd Approver ID";
                            Modify;
                            Message('Approval Request for Document No. ' + "Contract No." + ' has been Sent for further approval.');
                        end else
                            Error('You have not been set as 2nd approver');
                    end else
                        if "Approval Type" = "approval type"::"3rd Approval" then begin
                            if "Current Approver" = UserId then begin
                                "Approval Status" := "approval status"::Released;
                                "Approval Type" := "approval type"::None;
                                "Current Approver" := '';
                                "Approval Category" := "approval category"::" ";
                                "Last Modified Date" := Today;
                                "Approval Date" := Today;
                                Modify;
                                Message('Approval Request for Document No. ' + "Contract No." + 'has been fully Approved.');
                            end else
                                Error('You have not been set as 3rd approver');
                        end
    end;
end;
end;
end;

procedure RejectContractApprovalRequest(var ContractHeader: Record UnknownRecord50075)
begin
with ContractHeader do begin
//ContractMatrix.GET("User ID");
ContractMatrix.SetRange("User ID", "User ID");
ContractMatrix.SetRange(ContractMatrix."Approval Type", ContractMatrix."approval type"::Creation);
if ContractMatrix.FindFirst then begin
    if "Approval Status" <> "approval status"::"Pending approval" then begin
        Error('Only pending Documents can be Rejected');
    end else begin
        if Confirm('Reject this request?', false) = true then
            if ("Locked Status" = "locked status"::Unlocked) and ("Termination Status" = "termination status"::Active) then
                if "Approval Type" = "approval type"::"1st Approval" then begin
                    if "Current Approver" = UserId then begin
                        "Approval Status" := "approval status"::Open;
                        "Approval Type" := "approval type"::None;
                        "Current Approver" := '';
                        "Approval Category" := "approval category"::" ";
                        Modify;
                        Message('Approval Request for Document No. ' + "Contract No." + 'has been Rejected.');
                    end else
                        Error('You have not been set as 1st approver');
                end else
                    if "Approval Type" = "approval type"::"2nd Approval" then begin
                        if "Current Approver" = UserId then begin
                            "Approval Status" := "approval status"::Open;
                            "Approval Type" := "approval type"::None;
                            "Current Approver" := '';
                            "Approval Category" := "approval category"::" ";
                            Modify;
                            Message('Approval Request for Document No. ' + "Contract No." + 'has been Rejected.');
                        end else
                            Error('You have not been set as 2nd approver');
                    end else
                        if "Approval Type" = "approval type"::"3rd Approval" then begin
                            if "Current Approver" = UserId then begin
                                "Approval Status" := "approval status"::Open;
                                "Approval Type" := "approval type"::None;
                                "Current Approver" := '';
                                "Approval Category" := "approval category"::" ";
                                Modify;
                                Message('Approval Request for Document No. ' + "Contract No." + 'has been Rejected.');
                            end else
                                Error('You have not been set as 3rd approver');
                        end else
                            if "Approval Type" = "approval type"::"4th Approval" then begin
                                if "Current Approver" = UserId then begin
                                    "Approval Status" := "approval status"::Open;
                                    "Approval Type" := "approval type"::None;
                                    "Current Approver" := '';
                                    "Approval Category" := "approval category"::" ";
                                    Modify;
                                    Message('Approval Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                end else
                                    Error('You have not been set as 4th approver');
                            end else
                                if "Approval Type" = "approval type"::"5th Approval" then begin
                                    if "Current Approver" = UserId then begin
                                        "Approval Status" := "approval status"::Open;
                                        "Approval Type" := "approval type"::None;
                                        "Current Approver" := '';
                                        "Approval Category" := "approval category"::" ";
                                        Modify;
                                        Message('Approval Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                    end else
                                        Error('You have not been set as 5th approver');
                                end
    end;
end;
end;
end;

procedure DelegateContractApprovalRequest(var ContractHeader: Record UnknownRecord50075)
begin
with ContractHeader do begin
/* //ContractMatrix.GET("User ID");
  ContractMatrix.SETRANGE("User ID","User ID");
 IF ContractMatrix.FINDFIRST THEN BEGIN
       IF "Approval Status" <> "Approval Status"::"Pending approval" THEN
           ERROR('Only pending Documents can be Delegated')
       ELSE BEGIN
    IF ContractMatrix."Sustitute Approver ID" <> '' THEN BEGIN
     IF CONFIRM('Delegate this request?',FALSE)= TRUE THEN
         IF ("Locked Status" = "Locked Status"::Unlocked) AND ("Termination Status" = "Termination Status"::Active) THEN BEGIN
           "Current Approver" := ContractMatrix."Sustitute Approver ID";
           MODIFY;
           MESSAGE('Approval Request for Document No. '+"Contract No." +'has been Delegated.');
             END;
     END ELSE ERROR('Substitute approver has not been set for this user.');
 END;
END ELSE ERROR('You have not been setup as a user in Contrct approval setup');
END;*/

    /*             UserSetup.Get("Current Approver");
                if UserSetup.Substitute = '' then   //check if substitute is blank
                    Error('Substitute Approver has not been set for this user');
                SubstituteApprover.Get(UserSetup.Substitute);
                if SubstituteApprover."Approval Delegated" = true then begin  //if 1st substitute approver has delegated approvals
                    if (SubstituteApprover."Delegation Expiry" = Today) or (SubstituteApprover."Delegation Expiry" < Today) then begin //if delegation has expired
                        "Current Approver" := SubstituteApprover."User ID";
                        "Last Modified Date" := Today;
                        Modify;
                    end else
                        if (SubstituteApprover."Delegation Expiry" > Today) then begin //if delegation has not expired
                            if SubstituteApprover.Substitute <> '' then begin //if substitute for 1st substitute is set
                                UserSetup2.Get(SubstituteApprover.Substitute);
                                "Current Approver" := UserSetup2."User ID";
                                "Last Modified Date" := Today;
                                Modify;
                            end else
                                Error('Sustitute approver for user ' + SubstituteApprover.Substitute + ' Has not been set');
                        end;
                end else begin  //if 1st substitute has not delegated approvals
                    "Current Approver" := UserSetup.Substitute;
                    "Last Modified Date" := Today;
                    Modify;
                end
            end;

        end; */

    /*     procedure SubmitContractTerminationtForApproval(var ContractHeader: Record UnknownRecord50075)
        begin
            with ContractHeader do begin */

    //ContractMatrix.GET("User ID");
    /*  ContractMatrix.SetRange("User ID", "User ID");
     ContractMatrix.SetRange(ContractMatrix."Approval Type", ContractMatrix."approval type"::Termination);
     if ContractMatrix.FindFirst then begin

         if ("Approval Status" = "approval status"::Released) and ("Locked Status" = "locked status"::Unlocked) and ("Termination Status" = "termination status"::Active) then begin
             "Approval Type" := "approval type"::"1st Approval";
             "Termination Status" := "termination status"::"Pending Termination";
             "Current Approver" := ContractMatrix."1st Approver ID";
             "Approval Category" := "approval category"::"Create & Terminate";
             Modify;
             Message('Termination Request for Document No. ' + "Contract No." + 'has been Sent for approval.');
         end;
     end;
 end;
end;

procedure ApproveContractTerminationRequest(var ContractHeader: Record UnknownRecord50075)
begin
 with ContractHeader do begin
     //ContractMatrix.GET("User ID");
     ContractMatrix.SetRange("User ID", "User ID");
     ContractMatrix.SetRange(ContractMatrix."Approval Type", ContractMatrix."approval type"::Termination);
     if ContractMatrix.FindFirst then begin
         if "Approval Status" <> "approval status"::Released then begin
             Error('Only Approved Documents can be Terminated');
         end else
             if "Termination Status" <> "termination status"::"Pending Termination" then begin
                 Error('Only pending Termination Documents can be Terminated');
             end else begin
                 if Confirm('Approve this request?', false) = true then
                     if ("Locked Status" = "locked status"::Unlocked) and ("Termination Status" = "termination status"::"Pending Termination") then
                         if "Approval Type" = "approval type"::"1st Approval" then begin
                             if "Current Approver" = UserId then begin
                                 "Approval Type" := "approval type"::"2nd Approval";
                                 "Current Approver" := ContractMatrix."2nd Approver";
                                 Modify;
                                 Message('Termination Request for Document No. ' + "Contract No." + ' has been Sent for further approval.');

                             end else
                                 Error('You have not been set as 1st approver');
                             /* END ELSE IF "Approval Type" = "Approval Type"::"2nd Approval" THEN  BEGIN
                                IF ContractMatrix."2nd Approver" = USERID THEN BEGIN
                                  "Approval Type" := "Approval Type"::"3rd Approval";
                                  "Current Approver" := ContractMatrix."3rd Approver ID";
                              MODIFY;
                              MESSAGE('Termination Request for Document No. '+"Contract No." +' has been Sent for further approval.');
                              END ELSE ERROR('You have not been set as 2nd approver');*/
    /*                                 end else
                                        if "Approval Type" = "approval type"::"2nd Approval" then begin
                                            if "Current Approver" = UserId then begin
                                                "Termination Status" := "termination status"::Terminated;
                                                "Approval Type" := "approval type"::None;
                                                "Current Approver" := '';
                                                "Approval Category" := "approval category"::" ";
                                                "Last Modified Date" := Today;
                                                Modify;

                                                //Archive all related PO
                                                ContLines.Reset;
                                                ContLines.SetRange("Contract No.", "Contract No.");
                                                ContLines.SetRange("PO Created", true);
                                                if ContLines.FindFirst then begin
                                                    repeat
                                                        PurchHeader.Reset;
                                                        PurchHeader.SetRange("No.", ContLines."Purchase Order No.");
                                                        if PurchHeader.FindFirst then begin
                                                            PurchOrderCard.ArchiveContractDocuments(PurchHeader);
                                                        end;
                                                    until ContLines.Next = 0;
                                                end;
                                                //End Archive

                                                Message('Termination Request for Document No. ' + "Contract No." + ' has been fully Approved. and related PO`s archived');
                                            end else
                                                Error('You have not been set as 2nd approver');
                                        end
                        end;
                end;
            end

        end;

        procedure RejectContractTerminationRequest(var ContractHeader: Record UnknownRecord50075)
        begin
            with ContractHeader do begin
                //ContractMatrix.GET("User ID");
                ContractMatrix.SetRange("User ID", "User ID");
                ContractMatrix.SetRange(ContractMatrix."Approval Type", ContractMatrix."approval type"::Termination);
                if ContractMatrix.FindFirst then begin
                    if "Termination Status" <> "termination status"::"Pending Termination" then begin
                        Error('Only pending Documents can be Rejected');
                    end else begin
                        if Confirm('Reject this request?', false) = true then
                            if ("Locked Status" = "locked status"::Unlocked) and ("Termination Status" = "termination status"::"Pending Termination") then
                                if "Approval Type" = "approval type"::"1st Approval" then begin
                                    if "Current Approver" = UserId then begin
                                        "Termination Status" := "termination status"::Active;
                                        "Approval Type" := "approval type"::None;
                                        "Current Approver" := '';
                                        "Approval Category" := "approval category"::" ";
                                        Modify;
                                        Message('Termination Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                    end else
                                        Error('You have not been set as 1st approver');
                                end else
                                    if "Approval Type" = "approval type"::"2nd Approval" then begin
                                        if "Current Approver" = UserId then begin
                                            "Termination Status" := "termination status"::Active;
                                            "Approval Type" := "approval type"::None;
                                            "Current Approver" := '';
                                            "Approval Category" := "approval category"::" ";
                                            Modify;
                                            Message('Termination Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                        end else
                                            Error('You have not been set as 2nd approver');
                                    end else
                                        if "Approval Type" = "approval type"::"3rd Approval" then begin
                                            if "Current Approver" = UserId then begin
                                                "Termination Status" := "termination status"::Active;
                                                "Approval Type" := "approval type"::None;
                                                "Current Approver" := '';
                                                "Approval Category" := "approval category"::" ";
                                                Modify;
                                                Message('Termination Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                            end else
                                                Error('You have not been set as 3rd approver');
                                        end else
                                            if "Approval Type" = "approval type"::"4th Approval" then begin
                                                if "Current Approver" = UserId then begin
                                                    "Termination Status" := "termination status"::Active;
                                                    "Approval Type" := "approval type"::None;
                                                    "Current Approver" := '';
                                                    "Approval Category" := "approval category"::" ";
                                                    Modify;
                                                    Message('Termination Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                                end else
                                                    Error('You have not been set as 4th approver');
                                            end else
                                                if "Approval Type" = "approval type"::"5th Approval" then begin
                                                    if "Current Approver" = UserId then begin
                                                        "Termination Status" := "termination status"::Active;
                                                        "Approval Type" := "approval type"::None;
                                                        "Current Approver" := '';
                                                        "Approval Category" := "approval category"::" ";
                                                        Modify;
                                                        Message('Termination Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                                    end else
                                                        Error('You have not been set as 5th approver');
                                                end
                    end;
                end;
            end;
        end;

        procedure DelegateContractTerminationRequest(var ContractHeader: Record UnknownRecord50075)
        begin
            with ContractHeader do begin */
    /*//ContractMatrix.GET("User ID");
     ContractMatrix.RESET;
      ContractMatrix.SETRANGE("User ID","User ID");
      ContractMatrix.SETRANGE(ContractMatrix."Approval Type",ContractMatrix."Approval Type"::Termination);
     IF ContractMatrix.FINDFIRST THEN BEGIN
           IF "Termination Status" <> "Termination Status"::"Pending Termination" THEN
               ERROR('Only pending Termination Documents can be Delegated')
           ELSE BEGIN
        IF ContractMatrix."Sustitute Approver ID" <> '' THEN BEGIN
         IF CONFIRM('Delegate this request?',FALSE)= TRUE THEN
             IF ("Locked Status" = "Locked Status"::Unlocked) AND ("Renewal Status" <> "Renewal Status"::"Pending Renewal") THEN BEGIN
               "Current Approver" := ContractMatrix."Sustitute Approver ID";
               MODIFY;
               MESSAGE('Approval Request for Document No. '+"Contract No." +'has been Delegated.');
                 END;
         END ELSE ERROR('Substitute approver has not been set for this user.');
     END;
    END;*/
    /*             UserSetup.Get("Current Approver");
                if UserSetup.Substitute = '' then   //check if substitute is blank
                    Error('Substitute Approver has not been set for this user');
                SubstituteApprover.Get(UserSetup.Substitute);
                if SubstituteApprover."Approval Delegated" = true then begin  //if 1st substitute approver has delegated approvals
                    if (SubstituteApprover."Delegation Expiry" = Today) or (SubstituteApprover."Delegation Expiry" < Today) then begin //if delegation has expired
                        "Current Approver" := SubstituteApprover."User ID";
                        "Last Modified Date" := Today;
                        Modify;
                    end else
                        if (SubstituteApprover."Delegation Expiry" > Today) then begin //if delegation has not expired
                            if SubstituteApprover.Substitute <> '' then begin //if substitute for 1st substitute is set
                                UserSetup2.Get(SubstituteApprover.Substitute);
                                "Current Approver" := UserSetup2."User ID";
                                "Last Modified Date" := Today;
                                Modify;
                            end else
                                Error('Sustitute approver for user ' + SubstituteApprover.Substitute + ' Has not been set');
                        end;
                end else begin  //if 1st substitute has not delegated approvals
                    "Current Approver" := UserSetup.Substitute;
                    "Last Modified Date" := Today;
                    Modify;
                end
            end;


        end;

        procedure SubmitContractLockingtForApproval(var ContractHeader: Record UnknownRecord50075)
        begin
            with ContractHeader do begin
                //ContractMatrix.GET("User ID");
                ContractMatrix.Reset;
                ContractMatrix.SetRange("User ID", "User ID");
                if ContractMatrix.FindFirst then begin
                    if ("Termination Status" = "termination status"::Active) then begin
                        if "Locked Status" = "locked status"::Locked then begin
                            "Locked Status" := "locked status"::"Pending Unlocking";
                            "Approval Type" := "approval type"::"1st Approval";
                            "Current Approver" := ContractMatrix."1st Approver ID";
                            "Approval Category" := "approval category"::"Lock & Renew";
                            Modify;
                            Message('Unlocking Request Request for Document No. ' + "Contract No." + 'has been Sent for approval.')
                        end else
                            if "Locked Status" = "locked status"::Unlocked then begin
                                "Locked Status" := "locked status"::"Pending Locking";
                                "Approval Type" := "approval type"::"1st Approval";
                                "Current Approver" := ContractMatrix."1st Approver ID";
                                "Approval Category" := "approval category"::"Lock & Renew";
                                Modify;
                                Message('Locking Request Request for Document No. ' + "Contract No." + 'has been Sent for approval.');
                            end;
                    end else
                        Error('Field Termination status must be active.');
                end else
                    Error('you have not been setup as a user in contract approvals setup');
            end;
        end;

        procedure ApproveContractLockingRequest(var ContractHeader: Record UnknownRecord50075)
        begin
            with ContractHeader do begin
                ContractMatrix.Reset;
                ContractMatrix.SetRange("User ID", "User ID");
                if ContractMatrix.FindFirst then begin
                    //To Approve Locking.
                    if "Locked Status" = "locked status"::"Pending Locking" then begin
                        if Confirm('Approve this request?', false) = true then
                            if ("Termination Status" = "termination status"::Active) then
                                if "Approval Type" = "approval type"::"1st Approval" then begin
                                    if "Current Approver" = UserId then begin
                                        "Locked Status" := "locked status"::Locked;
                                        "Approval Type" := "approval type"::None;
                                        "Current Approver" := '';
                                        "Approval Category" := "approval category"::" ";
                                        "Last Modified Date" := Today;
                                        Modify;
                                        //
                                        //Lock all related PO's
                                        ContLines.Reset;
                                        ContLines.SetRange("Contract No.", "Contract No.");
                                        ContLines.SetRange("PO Created", true);
                                        if ContLines.FindFirst then begin
                                            repeat
                                                PurchHeader.Reset;
                                                PurchHeader.SetRange("No.", ContLines."Purchase Order No.");
                                                if PurchHeader.FindFirst then begin
                                                    PurchHeader.Lock := true;
                                                    PurchHeader.Modify;

                                                    PurchaseCard."LockPO`s"(PurchHeader);

                                                end;
                                            until ContLines.Next = 0;
                                            //END
                                        end;
                                        Message('This Contract no. ' + "Contract No." + ' and all related PO`s have been fully approved and locked');

                                        //
                                        //MESSAGE('Locking Request for Document No. '+"Contract No." +'has been Approved');
                                    end else
                                        Error('You have not been set as 1st approver for this user');
                                end;
                    end else
                        //To Approve UnLocking.
                        if "Locked Status" = "locked status"::"Pending Unlocking" then begin
                            if Confirm('Approve this request?', false) = true then
                                if ("Termination Status" = "termination status"::Active) then
                                    if "Approval Type" = "approval type"::"1st Approval" then begin
                                        if "Current Approver" = UserId then begin
                                            "Locked Status" := "locked status"::Unlocked;
                                            "Approval Type" := "approval type"::None;
                                            "Current Approver" := '';
                                            "Approval Category" := "approval category"::" ";
                                            "Last Modified Date" := Today;
                                            Modify;
                                            //Unlock all PO's Related to this Document.
                                            ContLines.Reset;
                                            ContLines.SetRange("Contract No.", "Contract No.");
                                            ContLines.SetRange("PO Created", true);
                                            if ContLines.FindFirst then begin
                                                repeat
                                                    PurchHeader.Reset;
                                                    PurchHeader.SetRange("No.", ContLines."Purchase Order No.");
                                                    if PurchHeader.FindFirst then begin
                                                        PurchHeader.Lock := false;
                                                        PurchHeader.Modify;
                                                    end;
                                                until ContLines.Next = 0;

                                            end;
                                            Message('Unlocking request for Contract no. ' + "Contract No." + ' has been fully approved and all related PO`s have been Unlocked');

                                            //
                                            //MESSAGE('UnLocking Request for Document No. '+"Contract No." +'has been Approved.');
                                        end else
                                            Error('You have not been set as 1st approver for this user');
                                    end
                        end
                end;
            end;
        end;

        procedure RejectContractLockingRequest(var ContractHeader: Record UnknownRecord50075)
        begin
            with ContractHeader do begin
                //ContractMatrix.GET("User ID");
                ContractMatrix.SetRange("User ID", "User ID");
                if ContractMatrix.FindFirst then begin
                    //To Reject Locking.
                    if "Locked Status" = "locked status"::"Pending Locking" then begin
                        if Confirm('Reject this request?', false) = true then
                            if ("Termination Status" = "termination status"::Active) then
                                if "Approval Type" = "approval type"::"1st Approval" then begin
                                    if "Current Approver" = UserId then begin
                                        "Locked Status" := "locked status"::Unlocked;
                                        "Approval Type" := "approval type"::None;
                                        "Current Approver" := '';
                                        "Approval Category" := "approval category"::" ";
                                        Modify;
                                        Message('Locking Request for Document No. ' + "Contract No." + 'has been rejected.');
                                    end else
                                        Error('You have not been set as 1st approver');
                                end else
                                    if "Approval Type" = "approval type"::"2nd Approval" then begin
                                        if "Current Approver" = UserId then begin
                                            "Locked Status" := "locked status"::Unlocked;
                                            "Approval Type" := "approval type"::None;
                                            "Current Approver" := '';
                                            "Approval Category" := "approval category"::" ";
                                            Modify;
                                            Message('Locking Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                        end else
                                            Error('You have not been set as 2nd approver');
                                    end else
                                        if "Approval Type" = "approval type"::"3rd Approval" then begin
                                            if "Current Approver" = UserId then begin
                                                "Locked Status" := "locked status"::Unlocked;
                                                "Approval Type" := "approval type"::None;
                                                "Current Approver" := '';
                                                "Approval Category" := "approval category"::" ";
                                                Modify;
                                                Message('Locking Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                            end else
                                                Error('You have not been set as 3th approver');
                                        end else
                                            if "Approval Type" = "approval type"::"4th Approval" then begin
                                                if "Current Approver" = UserId then begin
                                                    "Locked Status" := "locked status"::Unlocked;
                                                    "Approval Type" := "approval type"::None;
                                                    "Current Approver" := '';
                                                    "Approval Category" := "approval category"::" ";
                                                    Modify;
                                                    Message('Locking Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                                end else
                                                    Error('You have not been set as 4th');
                                            end else
                                                if "Approval Type" = "approval type"::"5th Approval" then begin
                                                    if "Current Approver" = UserId then begin
                                                        "Locked Status" := "locked status"::Unlocked;
                                                        "Approval Type" := "approval type"::None;
                                                        "Current Approver" := '';
                                                        "Approval Category" := "approval category"::" ";
                                                        Modify;
                                                        Message('Locking Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                                    end else
                                                        Error('You have not been set as 5th approver');
                                                end
                    end else
                        //To Reject UnLocking.
                        if "Locked Status" = "locked status"::"Pending Unlocking" then begin
                            if Confirm('Reject this request?', false) = true then
                                if ("Termination Status" = "termination status"::Active) then
                                    if "Approval Type" = "approval type"::"1st Approval" then begin
                                        if "Current Approver" = UserId then begin
                                            "Locked Status" := "locked status"::Locked;
                                            "Approval Type" := "approval type"::None;
                                            "Current Approver" := '';
                                            "Approval Category" := "approval category"::" ";
                                            Modify;
                                            Message('UnLocking Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                        end else
                                            Error('You have not been set as 1st approver');
                                    end else
                                        if "Approval Type" = "approval type"::"2nd Approval" then begin
                                            if "Current Approver" = UserId then begin
                                                "Locked Status" := "locked status"::Locked;
                                                "Approval Type" := "approval type"::None;
                                                "Current Approver" := '';
                                                "Approval Category" := "approval category"::" ";
                                                Modify;
                                                Message('Unlocking Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                            end else
                                                Error('You have not been set as 2nd approver');
                                        end else
                                            if "Approval Type" = "approval type"::"3rd Approval" then begin
                                                if "Current Approver" = UserId then begin
                                                    "Locked Status" := "locked status"::Locked;
                                                    "Approval Type" := "approval type"::None;
                                                    "Current Approver" := '';
                                                    "Approval Category" := "approval category"::" ";
                                                    Modify;
                                                    Message('Unlocking Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                                end else
                                                    Error('You have not been set as 3rd approver');
                                            end else
                                                if "Approval Type" = "approval type"::"4th Approval" then begin
                                                    if "Current Approver" = UserId then begin
                                                        "Locked Status" := "locked status"::Locked;
                                                        "Approval Type" := "approval type"::None;
                                                        "Current Approver" := '';
                                                        "Approval Category" := "approval category"::" ";
                                                        Modify;
                                                        Message('Approval Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                                    end else
                                                        Error('You have not been set as 4th approver');
                                                end else
                                                    if "Approval Type" = "approval type"::"5th Approval" then begin
                                                        if "Current Approver" = UserId then begin
                                                            "Locked Status" := "locked status"::Locked;
                                                            "Approval Type" := "approval type"::None;
                                                            "Current Approver" := '';
                                                            "Approval Category" := "approval category"::" ";
                                                            Modify;
                                                            Message('Approval Request for Document No. ' + "Contract No." + 'has been Rejected.');
                                                        end else
                                                            Error('You have not been set as 5th approver');
                                                    end
                        end
                end;
            end;
        end;

        procedure DelegateContractLockingRequest(var ContractHeader: Record UnknownRecord50075)
        begin
            with ContractHeader do begin
                //ContractMatrix.GET("User ID");
                ContractMatrix.SetRange("User ID", "User ID");
                if ContractMatrix.FindFirst then begin

                    if ("Locked Status" <> "locked status"::"Pending Locking") or ("Locked Status" <> "locked status"::"Pending Unlocking") then
                        Error('Only pending Documents can be Delegated')
                    else begin
                        if ContractMatrix."Sustitute Approver ID" <> '' then begin
                            if Confirm('Delegate this request?', false) = true then
                                if ("Termination Status" = "termination status"::Active) then begin
                                    "Current Approver" := ContractMatrix."Sustitute Approver ID";
                                    Modify;
                                    Message('Request for Document No. ' + "Contract No." + 'has been Delegated.');
                                end;
                        end else
                            Error('Substitute approver has not been set for this user.');
                    end;
                end;
            end;
        end; */
}

