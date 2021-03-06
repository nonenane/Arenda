﻿using Nwuram.Framework.Logging;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace dllArendaDictonary.dicLandPlot
{
    public partial class frmAdd : Form
    {
        public DataRowView row { set; private get; }

        private bool isEditData = false;
        private string oldName, oldObjectName, oldArea;
        private int id = 0, oldIdObject;        

        public frmAdd()
        {
            InitializeComponent();
            ToolTip tp = new ToolTip();
            tp.SetToolTip(btClose, "Выход");
            tp.SetToolTip(btSave, "Сохранить");
        }

        private void frmAdd_Load(object sender, EventArgs e)
        {
            init_combobox();
            if (row != null)
            {
                id = (int)row["id"];
                tbNumber.Text = (string)row["NumberPlot"];
                oldName = tbNumber.Text.Trim();

                cmbObject.SelectedValue = row["id_ObjectLease"];
                oldObjectName = cmbObject.Text.Trim();
                oldIdObject = (int)cmbObject.SelectedValue;

                tbArea.Text = row["AreaPlot"].ToString();
                oldArea = tbArea.Text.Trim();
            }

            isEditData = false;
        }

        private void frmAdd_FormClosing(object sender, FormClosingEventArgs e)
        {
            e.Cancel = isEditData && DialogResult.No == MessageBox.Show("На форме есть не сохранённые данные.\nЗакрыть форму без сохранения данных?\n", "Закрытие формы", MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
        }

        private void init_combobox()
        {
            Task<DataTable>task = Config.hCntMain.getObjectLease(false);
            task.Wait();
            DataTable dtObjectLease = task.Result;

            cmbObject.DisplayMember = "cName";
            cmbObject.ValueMember = "id";
            cmbObject.DataSource = dtObjectLease;
            cmbObject.SelectedIndex = -1;

        }

        private void btClose_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
        }

        private void tbArea_Leave(object sender, EventArgs e)
        {
            if (tbArea.Text.Length>0)
                tbArea.Text = decimal.Parse(tbArea.Text.ToString()).ToString("0.00");
        }

        private void btSave_Click(object sender, EventArgs e)
        {
            if (cmbObject.SelectedIndex == -1)
            {
                MessageBox.Show(Config.centralText($"Необходимо выбрать\n \"{lObject.Text}\"\n"), "Ошибка сохранения", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                cmbObject.Focus();
                return;
            }
                                  
            if (tbNumber.Text.Trim().Length == 0)
            {
                MessageBox.Show(Config.centralText($"Необходимо заполнить\n \"{lNumber.Text}\"\n"), "Ошибка сохранения", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                tbNumber.Focus();
                return;
            }
            
            if (tbArea.Text.Trim().Length == 0)
            {
                MessageBox.Show(Config.centralText($"Необходимо заполнить\n \"{lArea.Text}\"\n"), "Ошибка сохранения", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                tbArea.Focus();
                return;
            }


            Task<DataTable> task = Config.hCntMain.setLandPlot(id, tbNumber.Text, (int)cmbObject.SelectedValue, decimal.Parse(tbArea.Text), true, false, 0);
            task.Wait();

            DataTable dtResult = task.Result;

            if (dtResult == null || dtResult.Rows.Count == 0)
            {
                MessageBox.Show("Не удалось сохранить данные", "Ошибка сохранения", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }


            if ((int)dtResult.Rows[0]["id"] == -1)
            {
                MessageBox.Show("В справочнике уже присутствует должность с таким наименованием.", "Сохранение", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }


            if ((int)dtResult.Rows[0]["id"] == -9999)
            {
                MessageBox.Show("Произошла неведомая хрень.", "Ошибка сохранения", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (id == 0)
            {
                id = (int)dtResult.Rows[0]["id"];
                Logging.StartFirstLevel(1561);
                //Logging.Comment("Добавить Тип документа");
                Logging.Comment($"ID: {id}");
                Logging.Comment($"Объект расположения земельного участка ID:{cmbObject.SelectedValue}; Наименование: {cmbObject.Text}");
                Logging.Comment($"Номер земельного участка : {tbNumber.Text.Trim()}");
                Logging.Comment($"Размер земельного участка: {tbArea.Text.Trim()} м2");
                Logging.StopFirstLevel();
            }
            else
            {
                Logging.StartFirstLevel(1562);
                //Logging.Comment("Редактировать Тип документа");
                Logging.Comment($"ID: {id}");
                Logging.VariableChange($"Объект расположения земельного участка ID", cmbObject.SelectedValue, oldIdObject);
                Logging.VariableChange($"Объект расположения земельного участка Наименование", cmbObject.Text, oldObjectName);

                Logging.VariableChange($"Номер земельного участка", tbNumber.Text.Trim(), oldName);
                Logging.VariableChange($"Размер земельного участка", tbArea.Text.Trim(), oldArea);

                Logging.StopFirstLevel();
            }

            isEditData = false;
            MessageBox.Show("Данные сохранены.", "Сохранение данных", MessageBoxButtons.OK, MessageBoxIcon.Information);
            this.DialogResult = DialogResult.OK;
        }

        private void tbName_TextChanged(object sender, EventArgs e)
        {
            isEditData = true;
        }

        private void tbArea_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == '.')
            {
                e.KeyChar = ',';
            }
            if ((e.KeyChar == ',') && ((sender as TextBox).Text.ToString().Contains(e.KeyChar) || (sender as TextBox).Text.ToString().Length == 0))
            {
                e.Handled = true;
            }
            else if ((!Char.IsNumber(e.KeyChar) && (e.KeyChar != ',')) 
                || ((sender as TextBox).Text.Contains(',') && (sender as TextBox).Text.Length - 2>(sender as TextBox).Text.IndexOf(',') ))
            {
                if (e.KeyChar != '\b' && tbArea.SelectedText.Length!=tbArea.Text.Length)
                { e.Handled = true; }
            }

            //e.Handled = !char.IsDigit(e.KeyChar) && e.KeyChar != '\b';
        }
    }
}
