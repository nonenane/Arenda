﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Nwuram.Framework.Settings.Connection;
using System.Text.RegularExpressions;
using Nwuram.Framework.Logging;

namespace Arenda
{
    public partial class AdditionalDoc : Form
    {
        readonly Procedures _proc = new Procedures(ConnectionSettings.GetServer(), ConnectionSettings.GetDatabase(), ConnectionSettings.GetUsername(), ConnectionSettings.GetPassword(), ConnectionSettings.ProgramName);

        int _id, _id_type_doc, _id_type_dog;
        int y;
        string Area;
        string mes;
        DateTime start, stop, depart;
        DataTable dtTypes;
        private bool isNullRequestOut = false;
        private int? id_PetitionLeave = null;

        public AdditionalDoc(int id, DateTime str, DateTime st, int idtd)
        {
            InitializeComponent();
            _id = id;
            _id_type_dog = idtd;
            start = str;
            stop = st;
        }

        private void FormatSumms()
        {
            if (tbAreaNew.Text == "")
                tbAreaNew.Text = "0";
            tbAreaNew.Text = String.Format("{0:### ### ##0.00}", decimal.Parse(tbAreaNew.Text)).Trim();
        }

        private void fillcb()
        {
            dtTypes = _proc.FillCbTD();

            if ((dtTypes != null) && (dtTypes.Rows.Count > 0))
            {
                cbTypeDoc.DataSource = dtTypes;
                /*if (_id_type_dog == 3)
                    dtTypes.DefaultView.RowFilter = "id in (3, 6, 7)";*/
            }
            else
            {
                this.Close();
            }
        }


        private void btExit_Click(object sender, EventArgs e)
        {
            /*if (cbTypeDoc.Text != "" || dateadddoc.Value != start || dateren.Value != stop || tbAreaNew.Text != Area || dtpDeparture.Value != depart)
            {
                if (MessageBox.Show("На форме были внесены изменения. \nВыйти без сохранения?", "Запрос на выход", MessageBoxButtons.YesNo,
                                          MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) == DialogResult.Yes)
                { DialogResult = DialogResult.Cancel; }
            }
            else*/
            DialogResult = DialogResult.Cancel;
        }

        private void btAdd_Click(object sender, EventArgs e)
        {
            string num = "";
            decimal? AreaS;

            if (tbAreaNew.Text == Area)
            {
                AreaS = null;
            }
            else
            {
                AreaS = decimal.Parse(tbAreaNew.Text);
            }

            if (tbNumber.Text == "")
            { num = null; }
            else
            { num = tbNumber.Text; }

            if (cbTypeDoc.Text == "")
            {
                MessageBox.Show("Не выбран тип доп. документа.\nСохранение невозможно", "Сохранение доп.документа",
                                MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if ((tbAreaNew.Visible == true) && (tbAreaNew.Text == Area))
            {
                MessageBox.Show("Не заполнено поле \"Общ. площадь\".\nСохранение невозможно", "Сохранение доп.документа",
                                MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (CheckDate())
            {
                return;
            }

            DateTime? prolong;
            if (dateren.Visible == true)
                prolong = dateren.Value;
            else
                prolong = null;

            DateTime? departureDate;
            if (dtpDeparture.Visible == true)
                departureDate = dtpDeparture.Value;
            else
                departureDate = null;

            if (dtpOutDate.Visible)
                departureDate = dtpOutDate.Value.Date;

            string comment = null;
            if (tbComment.Visible)
                comment = tbComment.Text;



            _proc.AddeditTD(1, _id, Convert.ToDateTime(dateadddoc.Text), _id_type_doc, num, prolong, AreaS, departureDate, comment, id_PetitionLeave);

            Logging.StartFirstLevel(1402);
            //Logging.Comment("ID: " + id_DopDoc);
            Logging.Comment("№ документа: " + num);
            Logging.Comment("Тип документа ID: " + _id_type_doc + " ; Наименование: " + cbTypeDoc.Text);
            Logging.Comment("Дата документа: " + dateadddoc.Value.ToShortDateString());

            Logging.Comment("Данные арендатора, к которому добавляется доп.документ");
            Logging.Comment("Дата заключения договора: " + oldDoc.ToShortDateString());
            Logging.Comment("Номер договора: " + num_doc);
            Logging.Comment("Арендатор ID: " + _old_id_ten + "; Наименование: " + oldTen);
            Logging.Comment("Арендодатель ID: " + _old_id_lord + "; Наименование: " + oldLord);


            if (dateren.Visible) { Logging.Comment($"{label4.Text}: {dateren.Value.ToShortDateString()}"); }
            if (dtpDeparture.Visible) { Logging.Comment($"{lblDeparture.Text}: {dtpDeparture.Value.ToShortDateString()}"); }
            if (dtpOutDate.Visible) { Logging.Comment($"{label3.Text}: {dtpOutDate.Value.ToShortDateString()}"); }
            if(tbAreaNew.Visible) { Logging.Comment($"{lblAreaNew.Text}: {tbAreaNew.Text}"); }
            if (tbComment.Visible) { Logging.Comment($"{label4.Text}: {tbComment.Text}"); }



            Logging.Comment("Операцию выполнил: ID:" + Nwuram.Framework.Settings.User.UserSettings.User.Id
            + " ; ФИО:" + Nwuram.Framework.Settings.User.UserSettings.User.FullUsername);
            Logging.StopFirstLevel();

            MessageBox.Show("Данные сохранены.", "Сохранение доп.документа",MessageBoxButtons.OK,MessageBoxIcon.Information);
            DialogResult = DialogResult.Cancel;
        }

        private string num_doc, oldTen, oldLord;
        private int _old_id_ten, _old_id_lord;
        private DateTime oldDoc;

        public void setDocData(string num_doc, string oldTen, string oldLord, int _old_id_ten, int _old_id_lord, DateTime oldDoc)
        {
            this.num_doc = num_doc;
            this.oldTen = oldTen;
            this.oldLord = oldLord;

            this._old_id_ten = _old_id_ten;
            this._old_id_lord = _old_id_lord;

            this.oldDoc = oldDoc;
        }

        private void cbTypeDoc_SelectedValueChanged(object sender, EventArgs e)
        {
            if (cbTypeDoc.SelectedValue != null)
            {
                //DataTable dtTypeDoc = new DataTable();
                //dtTypeDoc = _proc.FillCbTD();
                //y = cbTypeDoc.SelectedIndex;
                //_id_type_doc = Convert.ToInt32(_proc.FillCbTD().Rows[y][0].ToString());
                _id_type_doc = int.Parse(cbTypeDoc.SelectedValue.ToString());
                y = dtTypes.Rows.IndexOf(dtTypes.Select("id = " + _id_type_doc.ToString())[0]);

                dateadddoc.Format = DateTimePickerFormat.Short;
                dateadddoc.Enabled = true;

                lblDeparture.Visible = false;
                dtpDeparture.Visible = false;
                lblAreaNew.Visible = false;
                tbAreaNew.Visible = false;
                label4.Visible = false;
                dateren.Visible = false;

                tbComment.Visible = false;
                dtpOutDate.Visible = false;
                tbNumber.Visible = true;
                tbError.Visible = false;

                this.Size = new Size(430, 192);


                label4.Text = "Дата продления\nдоговора";
                label3.Text = "№";
                dateadddoc.Location = new Point(128, 40);
                label2.Text = "Дата доп. документа:";
                //это чуть пониже вставить над
                tbNumber.Location = new Point(128, 70);
                label3.Location = new Point(12, 70);
                isNullRequestOut = false;
                dtpOutDate.Enabled = true;
                tbComment.Enabled = true;
                btAdd.Enabled = true;
                id_PetitionLeave = null;

                if (dtTypes.Rows[y]["NeedProlong"].ToString() == "True")
                {
                    label4.Text = "Дата продления \nдоговора";
                    mes = "Дата продления договора";
                    if (_proc.FillCbTD().Rows[y]["Rus_Name"].ToString() == "Соглашение о расторжении договора")
                    {
                        label4.Text = "Дата расторжения \nдоговора";
                        mes = "Дата расторжения договора";
                        lblDeparture.Visible = true;
                        dtpDeparture.Visible = true;
                    }

                    if (dtTypes.Rows[y]["Rus_Name"].ToString() == "Доп. соглашение на изменение площади")
                    {
                        label4.Text = "Дата вступления \nв силу";
                        mes = "Дата вступления в силу";
                    }

                    label4.Visible = true;
                    dateren.Visible = true;
                }


                if (dtTypes.Rows[y]["NeedChangeArea"].ToString() == "True")
                {
                    lblAreaNew.Visible = true;
                    tbAreaNew.Visible = true;
                }

                if (dtTypes.Rows[y]["Rus_Name"].Equals("Заявление на съезд"))
                {
                    label4.Visible = true;
                    label4.Text = "Примечание";
                    tbComment.Visible = true;
                    dtpOutDate.Visible = true;
                    label3.Text = "Планируемая дата съезда:";
                    tbNumber.Visible = false;
                    dateadddoc.Location = new Point(190, 40);
                    //dateadddoc.Enabled = false;

                    label2.Text = "Дата подачи заявления: ";
                    dtpOutDate.Location = new Point(190, 68);

                }
                else
                    if (dtTypes.Rows[y]["Rus_Name"].Equals("Аннуляция заявления на съезд"))
                {
                    this.Size = new Size(430, 215);

                    tbNumber.Visible = false;

                    label3.Text = "Дата подачи аннуляции на съезд";

                    label2.Text = "Дата подачи заявления на съезд";
                    dateadddoc.Location = new Point(312, 40);
                    dateadddoc.Enabled = false;

                    dtpOutDate.Visible = true;
                    dtpOutDate.Location = new Point(312, 91);

                    label4.Visible = true;
                    label4.Text = "Примечание";
                    tbComment.Visible = true;

                    tbError.Visible = true;

                    isNullRequestOut = true;
                    getDataNullRequestOut();
                }
            }
        }

        private void dateadddoc_ValueChanged(object sender, EventArgs e)
        {
            try
            {
                if (dateadddoc.Value.Date > dtpOutDate.Value.Date)
                    dtpOutDate.Value = dateadddoc.Value.Date;
            }
            catch { }
        }

        private void dtpOutDate_ValueChanged(object sender, EventArgs e)
        {
            try
            {
                if (dateadddoc.Value.Date > dtpOutDate.Value.Date)
                    dateadddoc.Value = dtpOutDate.Value.Date;
            }
            catch { }
        }

        private void dateadddoc_CloseUp(object sender, EventArgs e)
        {
            if (isNullRequestOut)
            {
                getDataNullRequestOut();
            }
        }

        private void dateadddoc_Leave(object sender, EventArgs e)
        {
            if (isNullRequestOut)
            {
                getDataNullRequestOut();
            }
        }

        private void getDataNullRequestOut()
        {
            DataTable dtTmp = _proc.getDataNullRequestOut(_id);
            if (dtTmp == null || dtTmp.Rows.Count == 0 || (int)dtTmp.Rows[0]["id"] == 0)
            {
                tbError.Text = "Заявление на съезда не найдено";
                this.tbError.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
                this.tbError.BackColor = Color.FromArgb(255, 0, 0);
                //this.tbError.BackColor = System.Drawing.Color.Red;
                //tbError.Font = new Font()
                dateadddoc.Format = DateTimePickerFormat.Custom;
                dateadddoc.CustomFormat = " ";
                dtpOutDate.Enabled = false;
                tbComment.Enabled = false;
                btAdd.Enabled = false;
                id_PetitionLeave = null;
            }
            else
            {
                this.tbError.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
                tbError.Text = "Заявление на съезда найдено";
                this.tbError.BackColor = Color.FromArgb(0, 127, 14);
                dateadddoc.Format = DateTimePickerFormat.Short;
                dateadddoc.Value = ((DateTime)dtTmp.Rows[0]["DateDocument"]).Date;
                dtpOutDate.Enabled = true;
                tbComment.Enabled = true;
                btAdd.Enabled = true;
                id_PetitionLeave = (int)dtTmp.Rows[0]["id"];
            }

        }

        private bool CheckDate()
        {
            if (cbTypeDoc.SelectedValue != null)
            {
                if (dateadddoc.Value < start)
                {
                    MessageBox.Show("Дата доп. документа \nне должна быть меньше даты договора",
                        "Проверка перед сохранением",MessageBoxButtons.OK,MessageBoxIcon.Warning);
                    return true;
                }

                if (dateren.Visible == true)
                {
                    if ((dtTypes.Rows[y][1].ToString() == "Соглашение о расторжении договора")
                          || (dtTypes.Rows[y][1].ToString() == "Доп. соглашение на изменение площади"))
                    {
                        if (dateren.Value < start)
                        {
                            MessageBox.Show(mes + " не должна быть \nменьше даты договора",
                                "Проверка перед сохранением", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return true;
                        }
                    }
                    else
                    {
                        if (dateren.Value < stop)
                        {
                            MessageBox.Show(mes + " не должна быть \nменьше даты окончания договора +1 ", 
                                "Проверка перед сохранением", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return true;
                        }
                    }
                }

                if (dtpDeparture.Visible == true)
                {
                    DataTable dtAgreement = _proc.GetLD(_id);

                    if ((dtAgreement == null) || (dtAgreement.Rows.Count == 0))
                    {
                        MessageBox.Show("Ошибка получения данных по договору!", 
                            "Проверка перед сохранением", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return true;
                    }

                    DateTime AgrDate = DateTime.Parse(dtAgreement.Rows[0]["Date_of_Conclusion"].ToString()).Date;
                    if (dtpDeparture.Value.Date < AgrDate)
                    {
                        MessageBox.Show("Дата договора - " + AgrDate.ToShortDateString() + "\nДата выезда не может быть меньше!", 
                            "Проверка перед сохранением", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return true;
                    }
                }

                DataTable dtCheckSameDocTypeAndDateExists = new DataTable();
                dtCheckSameDocTypeAndDateExists = _proc.CheckSameDocTypeAndDateExists(
                            _id,
                            int.Parse(cbTypeDoc.SelectedValue.ToString()),
                            dateadddoc.Value.Date);

                if (dtCheckSameDocTypeAndDateExists.Rows.Count > 0)
                {
                    if (dtCheckSameDocTypeAndDateExists.Columns.Contains("msg"))
                    {
                        MessageBox.Show(TempData.centralText(dtCheckSameDocTypeAndDateExists.Rows[0]["msg"].ToString().Replace(@"\n", "\n")), 
                            "Проверка перед сохранением", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return true;
                    }
                    else
                    {
                        MessageBox.Show(TempData.centralText("Для договора уже существует документ \n\"" + cbTypeDoc.Text
                            + "\" от " + dateadddoc.Value.ToShortDateString() + "\nСохранение невозможно.\n"), "Проверка перед сохранением", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return true;
                    }
                }

                //если выбрано "Доп.соглашение на изменение площади"
                if (int.Parse(cbTypeDoc.SelectedValue.ToString()) == 5)
                {
                    if (CheckPaymentsOnMonthth(_id, dateren.Value.Date, "Дата вступления в силу"))
                    {
                        return true;
                    }
                }

                //если выбрано "Соглашение о расторжении договора"
                if (int.Parse(cbTypeDoc.SelectedValue.ToString()) == 4)
                {
                    if (CheckPaymentsOnMonthth(_id, dtpDeparture.Value.Date, "Дата выезда"))
                    {
                        return true;
                    }
                }
                return false;
            }
            return false;
        }

        private bool CheckPaymentsOnMonthth(int id, DateTime date, string CalendarName)
        {
            bool res = false;

            DataTable dt = new DataTable();
            dt = _proc.CheckPaymentsOnMonth(id, date);

            if (dt.Rows.Count > 0)
            {
                MessageBox.Show("За месяц, выбранный в календаре \n\"" + CalendarName
                    + "\", уже имеются оплаты по договору. \nСохранение дополнительного документа невозможно.", "Проверка перед сохранением", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return true;
            }

            return res;
        }

        private void tbNumber_KeyPress(object sender, KeyPressEventArgs e)
        {
            /*Regex pat = new Regex(@"[\b]|[0-9]|[\s]");
            bool b = pat.IsMatch(e.KeyChar.ToString());
            if (b == false)
            {
                e.Handled = true;
            }*/
        }

        private void tbAreaNew_Leave(object sender, EventArgs e)
        {
            FormatSumms();
        }

        private void lockSimbols(KeyPressEventArgs e)
        {
            Regex pat = new Regex(@"[\b]|[0-9]|[,]");
            bool b = pat.IsMatch(e.KeyChar.ToString());
            if (b == false)
            {
                e.Handled = true;
            }

        }

        private void tbAreaNew_KeyPress(object sender, KeyPressEventArgs e)
        {
            lockSimbols(e);
        }

        private void AdditionalDoc_Load(object sender, EventArgs e)
        {
            fillcb();
            label4.Visible = false;
            dateren.Visible = false;
            lblAreaNew.Visible = false;
            tbAreaNew.Visible = false;

            start = dateadddoc.Value = start;
            depart = dtpDeparture.Value = stop = dateren.Value = stop.AddDays(1);
            FormatSumms();
            Area = tbAreaNew.Text;
        }

    }
}
