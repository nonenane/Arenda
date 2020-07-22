﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Nwuram.Framework.Settings.Connection;
using Nwuram.Framework.Logging;
using System.IO;

namespace Arenda
{
    public partial class frmAddPayment : Form
    {
        readonly Procedures _proc = new Procedures(ConnectionSettings.GetServer(), ConnectionSettings.GetDatabase(), ConnectionSettings.GetUsername(), ConnectionSettings.GetPassword(), ConnectionSettings.ProgramName);
        string mode, num;
        int id;
        int id_agreement;
        bool Reklama;
        string defaultVal = "0.00";
        decimal Phone = 0;
        bool load = false;
        bool Running = false;

        DateTime oldDate = DateTime.Now;
        string oldSum;
        int oldSign;
        DataTable dtY;

        public frmAddPayment(int _id, int _id_agreement, string _num, bool _Reklama)
        {
            id = _id;
            id_agreement = _id_agreement;
            Reklama = _Reklama;
            mode = (_id == 0) ? "add" : "edit";
            num = _num;            
            InitializeComponent();
        }

        private void frmAddPayment_Load(object sender, EventArgs e)
        {
            load = true;
            
            EmptyAlgoritmResults();

            DateTime CurDate = _proc.getCurDate();

            int sign = 0;

            Enabled(true);

            if (mode == "add")
            {
                this.Text = "Добавить оплату договора № " + num;
                if (Reklama)
                {
                    rbRek.Checked = true;
                    sign = 2;
                }
                
                dtpDate.Value = CurDate.Date;
            }
            else
            {
                this.Text = "Редактировать оплату договора № " + num;
                DataTable dt = new DataTable();
                dt = _proc.GetPayments(id_agreement);
                DataRow dr = dt.Select("id=" + id)[0];

                dtpDate.Value = DateTime.Parse(dr["PaymentDate"].ToString());
                txtSum.Text = dr["PaymentSum"].ToString();

                if (!Reklama)
                {
                    sign = int.Parse(dr["isPayment"].ToString());
                }
                else
                {
                    sign = 2;
                }                
                
                if (sign == 0)
                    rbAr.Checked = true;
                if (sign == 2)
                    rbRek.Checked = true;
            }
            oldDate = dtpDate.Value.Date;
            oldSum = txtSum.Text = numTextBox.CheckAndChange(txtSum.Text, 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}");

            oldSign = sign;            

            dtpDate.MaxDate = CurDate;

            lblTel.Visible
                = txtTel.Visible
                = lblTelRub.Visible
                = false;

            load = false;
        }

        private void Enabled(bool isActive)
        {
            foreach (Control con in this.Controls)
            {
                con.Enabled = isActive;
            }

            if (isActive)
            {
                if (Reklama)
                {
                    rbAr.Enabled = false;
                    rbRek.Enabled = true;                    
                }
                else
                {
                    rbAr.Enabled = true;
                    rbRek.Enabled = false;
                }
            }
        }

        private void btnQuit_Click(object sender, EventArgs e)
        {
            int curSign = 0;            
            if (rbRek.Checked)
                curSign = 2;

            if ((oldDate != dtpDate.Value) || (oldSum != txtSum.Text) || (curSign != oldSign))
            {
                DialogResult d = MessageBox.Show("На форме есть несохраненные данные. \nЗакрыть форму без сохранения?", "Закрытие формы", MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                if (d == DialogResult.Yes)
                {
                    this.Close();
                }
            }
            else
            {
                this.Close();
            }
            
        }

        private void txtSum_KeyPress(object sender, KeyPressEventArgs e)
        {
            numTextBox.KeyPress(txtSum, e, false, false);

            if (e.KeyChar == '\r')
            {
                Algoritm();
            }                     
        }

        private void txtSum_Leave(object sender, EventArgs e)
        {
            txtSum.Text = numTextBox.CheckAndChange(txtSum.Text, 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}");

            Algoritm();
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            if (txtSum.Text == defaultVal)
            {
                MessageBox.Show("Введите сумму оплаты!");
                return;
            }

            DataTable dtAgreement = new DataTable();
            dtAgreement = _proc.GetLD(id_agreement);

            if ((dtAgreement == null) || (dtAgreement.Rows.Count == 0))
            {
                MessageBox.Show("Ошибка получения данных по договору!");
                return;
            }

            DateTime AgrDate = DateTime.Parse(dtAgreement.Rows[0]["Date_of_Conclusion"].ToString()).Date;
            if (dtpDate.Value.Date < AgrDate)
            {
                MessageBox.Show("Дата договора - " + AgrDate.ToShortDateString() + "\nДата оплаты не может быть меньше!");
                return;
            }            

            int curSign = 0;            
            if (rbRek.Checked)
                curSign = 2;

            DataTable dtAfterPayments = new DataTable();
            dtAfterPayments = _proc.CheckAfterPayments(id, id_agreement, dtpDate.Value.Date);

            if ((dtAfterPayments == null) || (dtAfterPayments.Rows.Count == 0))
            {
                return;                
            }

            if (int.Parse(dtAfterPayments.Rows[0][0].ToString())>0)
            {
                MessageBox.Show("Для договора заведена оплата на более позднюю дату. \nСохранение невозможно. \nВыберите другую дату или удалите \nзапись с более поздней датой!", "Сообщение", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }                             


            DataTable dt = new DataTable();
            dt = _proc.CheckAnotherPayment(id,
                                 id_agreement,
                                 dtpDate.Value.Date,
                                 decimal.Parse(numTextBox.ConvertToCompPunctuation(txtSum.Text))                                 
                                 );

            if ((dt != null) && (dt.Rows.Count > 0))
            {
                if (int.Parse(dt.Rows[0][0].ToString()) > 0)
                {
                    DialogResult d = MessageBox.Show("За одну дату производится \nповторная оплата. \nСохранить введенную оплату?", "Сохранение данных", MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                    if (d == DialogResult.Yes)
                    {
                        save();
                    }
                }
                else
                {
                    save();
                }
            }
            else
            {
                //MessageBox.Show("Ошибка соединения с сервером");
                return;
            }
        }

        private void save()
        {
            if (dtY == null)
            {
                MessageBox.Show("Ошибка расчета данных");
                return;
            }

            int curSign = 0;            
            if (rbRek.Checked)
                curSign = 2;

            int id_row = 0;
            
            DataTable dt = new DataTable();
            dt = _proc.AddEditPayment(id,
                     id_agreement,
                     dtpDate.Value.Date,
                     decimal.Parse(numTextBox.ConvertToCompPunctuation(txtSum.Text))                     
                     );

            if ((dt != null) && (dt.Rows.Count > 0))
            {
                id_row = int.Parse(dt.Rows[0]["id"].ToString());
            }
            else
            {
                MessageBox.Show("Ошибка!");
                return;
            }

            Logging.StartFirstLevel(181);

            string operation = "";
            if (mode == "add")
            {
                operation = "Добавление оплаты по договору № " + num + ", id договора = " + id_agreement.ToString();

                Logging.Comment(operation);
                Logging.Comment("");
                Logging.Comment("id оплаты = " + id_row.ToString());
                Logging.Comment("Дата: " + dtpDate.Value.ToShortDateString());
                Logging.Comment("Сумма оплаты: " + txtSum.Text);
                Logging.Comment("Признак оплаты: " + (rbAr.Checked ? "Аренда" : "Реклама"));
                Logging.Comment("");
                Logging.Comment("Оплата просрочена на " + dt.Rows[0]["days"].ToString() + " дней."); 
                Logging.Comment("Начислено пени в размере " + numTextBox.CheckAndChange(dt.Rows[0]["peni"].ToString(), 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}") + " руб. "); 
                Logging.Comment("В оплату принято " + numTextBox.CheckAndChange(dt.Rows[0]["payed"].ToString(), 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}") + " руб. ");
                Logging.Comment("Итого долг равен " + numTextBox.CheckAndChange(dt.Rows[0]["debt"].ToString(), 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}") + " руб. ");                
            }
            else
            {
                operation = "Редактирование оплаты по договору № " + num + ", id договора = " + id_agreement.ToString();

                Logging.Comment(operation);
                Logging.Comment("");
                Logging.Comment("id оплаты = " + id.ToString());
                Logging.VariableChange("Дата", dtpDate.Value.ToShortDateString(), oldDate.ToShortDateString());
                Logging.VariableChange("Сумма оплаты", txtSum.Text, oldSum);
                Logging.VariableChange("Признак оплаты",
                    (rbAr.Checked ? "Аренда" : "Реклама"),
                    (oldSign == 0) ? "Аренда" : "Реклама");
                Logging.Comment("");
                Logging.Comment("Оплата просрочена на " + dt.Rows[0]["days"].ToString() + " дней.");
                Logging.Comment("Начислено пени в размере " + numTextBox.CheckAndChange(dt.Rows[0]["peni"].ToString(), 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}") + " руб. ");
                Logging.Comment("В оплату принято " + numTextBox.CheckAndChange(dt.Rows[0]["payed"].ToString(), 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}") + " руб. ");
                Logging.Comment("Итого долг равен " + numTextBox.CheckAndChange(dt.Rows[0]["debt"].ToString(), 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}") + " руб. ");
            }

            if (TempData.SumDebtAfterCount != 0)
            {
                Logging.Comment("Оплатить до " + TempData.dateToPayAfterCount.Date.ToShortDateString());
            }

            Logging.Comment("Итого переплата "                             
                + numTextBox.CheckAndChange(
                    TempData.PereplataAfterCount.ToString(),
                    2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}")
                + " руб. ");
            Logging.Comment("");

            oldDate = dtpDate.Value;
            oldSum = txtSum.Text = numTextBox.CheckAndChange(txtSum.Text, 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}");

            oldSign = 0;
            if (rbRek.Checked)
                oldSign = 2;

            saveDetails(id_row);
            
            decimal sumPay = decimal.Parse(numTextBox.ConvertToCompPunctuation(txtSum.Text));

            decimal pen = Convert.ToDecimal(dtY.Compute("Sum(Peni)", ""));

            decimal payed = sumPay - pen;

            MessageBox.Show("Оплата "
                +                 
                numTextBox.CheckAndChange(
                    sumPay.ToString(), 
                    2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}")
                + " руб. просрочена на "
                + Convert.ToInt32(dtY.Compute("Max(Pr)", "")).ToString()
                + " дней. "
                + "\nНачислено пени в размере "
                + numTextBox.CheckAndChange(
                    pen.ToString(), 
                    2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}")
                + " руб. "
                + "\nВ оплату принято " 
                + numTextBox.CheckAndChange(
                    payed.ToString(), 
                    2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}")                                
                + " руб. "
                + "\n\nИтого долг равен "
                + numTextBox.CheckAndChange(
                    TempData.SumDebtAfterCount.ToString(), 
                    2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}")                
                + " руб. "
                + ((TempData.SumDebtAfterCount == 0) ? "" : "\nОплатить до " + TempData.dateToPayAfterCount.Date.ToShortDateString())
                + "\nИтого переплата "
                + numTextBox.CheckAndChange(
                    TempData.PereplataAfterCount.ToString(),
                    2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}")
                + " руб. "
                + ((TempData.isFullPayed) ? ("\n\nДоговор оплачен полностью.") : "")
                );

            PrintSavedResults("Результат сохранения оплаты", true);

            if (TempData.isFullPayed)
            {
                _proc.FullPayed(id_agreement, true);
                Logging.Comment("");
                Logging.Comment("Договор полностью оплачен.");
            }

            Logging.Comment("");
            Logging.Comment("Завершение операции \"" + operation + "\"");
            Logging.StopFirstLevel();

            this.Close();
        }

        private string Month(int numMonth)
        {
            string res = "";
            switch (numMonth)
            {
                case 1: { res = "январь"; break; }
                case 2: { res = "февраль"; break; }
                case 3: { res = "март"; break; }
                case 4: { res = "апрель"; break; }
                case 5: { res = "май"; break; }
                case 6: { res = "июнь"; break; }
                case 7: { res = "июль"; break; }
                case 8: { res = "август"; break; }
                case 9: { res = "сентябрь"; break; }
                case 10: { res = "октябрь"; break; }
                case 11: { res = "ноябрь"; break; }
                case 12: { res = "декабрь"; break; }                
            }

            return res;
        }

        private void PrintSavedResults(string MessageText, bool show)
        {            
            List<string> tmp;
            tmp = new List<string> { " ", MessageText };

            string text;

            if (dtY.Rows.Count > 0)
            {
                if (show)
                {
                    for (int i = 0; dtY.Rows.Count > i; i++)
                    {
                        DateTime monYear = DateTime.Parse(dtY.Rows[i]["Month"].ToString());

                        text = "Сумма оплаты: " + dtY.Rows[i]["Summa"]
                            + ", Пени: " + dtY.Rows[i]["Peni"]
                            + ", Просрочка(дн): " + dtY.Rows[i]["Pr"]
                            + ", Месяц: "
                            + Month(monYear.Month) + " " + monYear.Year.ToString()
                            + ", За телефон: " + dtY.Rows[i]["Phone"];

                        tmp.Add(text);

                        Logging.Comment(text);
                    }                    
                    File.WriteAllLines(Application.StartupPath + @"\\result.txt", tmp.ToArray());
                    System.Diagnostics.Process.Start("notepad.exe", Application.StartupPath + @"\\result.txt");
                }
            }
        }

        private void saveDetails(int id_row)
        {
            for (int i = 0; dtY.Rows.Count > i; i++)
            {                                
                int id_detail = 0;
                id_detail = _proc.AddPaymentDetails(
                    id_row, 
                    decimal.Parse(dtY.Rows[i]["Summa"].ToString()),
                    int.Parse(dtY.Rows[i]["Pr"].ToString()),
                    decimal.Parse(dtY.Rows[i]["Peni"].ToString()),
                    DateTime.Parse(dtY.Rows[i]["Month"].ToString()),                    
                    decimal.Parse(dtY.Rows[i]["Phone"].ToString()));
            }            
        }

        private void Algoritm()
        {
            if (!Running)
            {
                Running = true;
                if (!bgwToExcel.IsBusy)
                {
                    prbExcel.Visible = true;
                    Enabled(false);
                    bgwToExcel.RunWorkerAsync();
                }
            }
        }

        private void dtpDate_ValueChanged(object sender, EventArgs e)
        {
            if (!load)
            {
                Algoritm();
            }
        }

        private void EmptyAlgoritmResults()
        {
            dtY = null;
            TempData.SumProgAfterCount = 0;
        }


        
        private void frmAddPayment_Click(object sender, EventArgs e)
        {
            btnSave.Focus();
        }

        private void bgwToExcel_DoWork(object sender, DoWorkEventArgs e)
        {
            bgwToExcel.WorkerSupportsCancellation = false;

            decimal SumProg = decimal.Parse(numTextBox.ConvertToCompPunctuation(txtSum.Text));

            if (SumProg == 0)
            {
                EmptyAlgoritmResults();
                return;
            }
            
            DataTable dt = new DataTable();
            dt = _proc.GetLD(id_agreement);

            if ((dt == null) || (dt.Rows.Count == 0))
            {
                MessageBox.Show("Ошибка получения данных");
                return;
            }

            DateTime StartDate = DateTime.Parse(dt.Rows[0]["Start_Date"].ToString());
            DateTime DateEnd = GetX.GetDateEnd(dt, id_agreement);                

            //кол-во дней в месяце из DateStart
            int countDaysStart = GetX.getCountDays(StartDate);
            //кол-во дней в месяце из DateEnd
            int countDaysEnd = GetX.getCountDays(DateEnd);            

            decimal TS = (Reklama) ? decimal.Parse(dt.Rows[0]["Reklama"].ToString())
                                   : decimal.Parse(dt.Rows[0]["Total_Sum"].ToString());

            decimal OST = TS * (countDaysStart - StartDate.Day + 1) / countDaysStart;
            OST = Math.Round(OST, 2);

            decimal L = TS / countDaysEnd * DateEnd.Day;
            L = Math.Round(L, 2);
            
            decimal Cost_of_Meter = decimal.Parse(dt.Rows[0]["Cost_of_Meter"].ToString());

            Phone = (Reklama) ? 0 : decimal.Parse(dt.Rows[0]["Phone"].ToString());

            DataTable dtX = new DataTable();
            dtX = GetX.GetXtable(StartDate, DateEnd, TS, OST, L, Reklama, Cost_of_Meter, Phone, id_agreement);
                

            if ((dtX == null) || (dtX.Rows.Count == 0))
            {
                MessageBox.Show("Ошибка получения данных");
                return;
            }            
                        
            decimal Sopl = _proc.GetSopl(id_agreement);

            decimal N = _proc.GetSettings("pnar", 0);
                       

            //процедура получения Y
            dtY = GetY.GetYtable(dtX, Sopl, StartDate.Day, N, dtpDate.Value.Date, SumProg, Phone, id_agreement);
        }

        private void ShowTel(bool isActive)
        {
            lblTel.Visible
                    = txtTel.Visible
                    = lblTelRub.Visible
                    = isActive;
        }

        private void bgwToExcel_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            Running = false;
            prbExcel.Visible = false;
            Enabled(true);

            if (TempData.SumProgAfterCount > 0)
            {
                ShowTel(false);

                MessageBox.Show("Введенная сумма превышает максимальную \nсумму по договору на " + TempData.SumProgAfterCount.ToString());

                txtTel.Text = numTextBox.CheckAndChange(defaultVal, 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}");
                txtSum.Text = numTextBox.CheckAndChange(defaultVal, 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}");

                EmptyAlgoritmResults();
            }
            else
            {
                if ((Reklama) || (Phone == 0))
                {
                    ShowTel(false);
                }
                else
                {
                    if (dtY != null)
                    {
                        decimal ph = 0;
                        for (int i = 0; dtY.Rows.Count > i; i++)
                        {
                            ph += decimal.Parse(dtY.Rows[i]["Phone"].ToString());
                        }

                        if (ph > 0)
                        {
                            ShowTel(true);

                            txtTel.Text = numTextBox.CheckAndChange(ph.ToString(), 2, 0, 9999999999, false, defaultVal, "{0:# ### ### ##0.00}");
                        }
                        else
                        {
                            ShowTel(false);
                        }
                    }
                    else
                    {
                        ShowTel(false);
                    }
                }
            }

            

        }
    }
}
