﻿using System.Text;
using System.Collections;
using Nwuram.Framework.Data;
using Nwuram.Framework.Settings.Connection;
using System.Data;
using System;
using Nwuram.Framework.Settings.User;
using System.Threading.Tasks;
using System.Threading;

namespace dllJournalLoad1C
{
    class Procedures : SqlProvider
    {
        public Procedures(string server, string database, string username, string password, string appName)
              : base(server, database, username, password, appName)
        {
        }
        ArrayList ap = new ArrayList();

        #region ""

        /// <summary>
        /// Получение списка объектов
        /// </summary>
        /// <param name=""></param>
        /// <returns>Таблица с данными</returns>        
        public DataTable getObjectLease(bool withAllDeps = false)
        {
            ap.Clear();

            DataTable dtResult = executeProcedure("[Arenda].[spg_getObjectLease]",
                 new string[0] { },
                 new DbType[0] { }, ap);

            if (withAllDeps)
            {
                if (dtResult != null)
                {
                    if (!dtResult.Columns.Contains("isMain"))
                    {
                        DataColumn col = new DataColumn("isMain", typeof(int));
                        col.DefaultValue = 1;
                        dtResult.Columns.Add(col);
                        dtResult.AcceptChanges();
                    }

                    DataRow row = dtResult.NewRow();

                    row["cName"] = "Все Объекты";
                    row["id"] = 0;
                    row["isMain"] = 0;
                    row["isActive"] = 1;
                    dtResult.Rows.Add(row);
                    dtResult.AcceptChanges();
                    dtResult.DefaultView.RowFilter = "isActive = 1";
                    dtResult.DefaultView.Sort = "isMain asc, cName asc";
                    dtResult = dtResult.DefaultView.ToTable().Copy();
                }
            }
            else
            {
                dtResult.DefaultView.RowFilter = "isActive = 1";
                dtResult.DefaultView.Sort = "cName asc";
                dtResult = dtResult.DefaultView.ToTable().Copy();
            }

            return dtResult;
        }

        /// <summary>
        /// Получение списка объектов
        /// </summary>
        /// <param name=""></param>
        /// <returns>Таблица с данными</returns>        
        public DataTable getTypeContract(bool withAllDeps = false)
        {
            ap.Clear();

            DataTable dtResult = executeProcedure("[Arenda].[spg_getTypeContract]",
                 new string[0] { },
                 new DbType[0] { }, ap);

            if (withAllDeps)
            {
                if (dtResult != null)
                {
                    if (!dtResult.Columns.Contains("isMain"))
                    {
                        DataColumn col = new DataColumn("isMain", typeof(int));
                        col.DefaultValue = 1;
                        dtResult.Columns.Add(col);
                        dtResult.AcceptChanges();
                    }

                    DataRow row = dtResult.NewRow();

                    row["cName"] = "Все типы";
                    row["id"] = 0;
                    row["isMain"] = 0;
                    row["isActive"] = 1;
                    dtResult.Rows.Add(row);
                    dtResult.AcceptChanges();
                    dtResult.DefaultView.RowFilter = "isActive = 1";
                    dtResult.DefaultView.Sort = "isMain asc, cName asc";
                    dtResult = dtResult.DefaultView.ToTable().Copy();
                }
            }
            else
            {
                dtResult.DefaultView.RowFilter = "isActive = 1";
                dtResult.DefaultView.Sort = "cName asc";
                dtResult = dtResult.DefaultView.ToTable().Copy();
            }

            return dtResult;
        }

        public DataTable GetListLandlord(bool withAllDeps = false)
        {
            ap.Clear();

            DataTable dtResult = executeProcedure("[Arenda].[GetListLandlord]",
                 new string[0] { },
                 new DbType[0] { }, ap);

            if (withAllDeps)
            {
                if (dtResult != null)
                {
                    if (!dtResult.Columns.Contains("isMain"))
                    {
                        DataColumn col = new DataColumn("isMain", typeof(int));
                        col.DefaultValue = 1;
                        dtResult.Columns.Add(col);
                        dtResult.AcceptChanges();
                    }

                    DataRow row = dtResult.NewRow();

                    row["cName"] = "Все арендодатели";
                    row["id"] = 0;
                    row["isMain"] = 0;
                    row["isActive"] = 1;
                    dtResult.Rows.Add(row);
                    dtResult.AcceptChanges();
                    dtResult.DefaultView.RowFilter = "isActive = 1";
                    dtResult.DefaultView.Sort = "isMain asc, cName asc";
                    dtResult = dtResult.DefaultView.ToTable().Copy();
                }
            }
            else
            {
                dtResult.DefaultView.RowFilter = "isActive = 1";
                dtResult.DefaultView.Sort = "cName asc";
                dtResult = dtResult.DefaultView.ToTable().Copy();
            }

            return dtResult;
        }

        public DataTable GetListJournalLoad1C(int id_object,DateTime dateStart,DateTime dateEnd)
        {
            ap.Clear();
            ap.Add(id_object);
            ap.Add(dateStart);
            ap.Add(dateEnd);

            return executeProcedure("Arenda.GetListJournalLoad1C",
              new string[3] { "@id_object", "@dateStart", "@dateEnd" },
              new DbType[3] { DbType.Int32,DbType.Date,DbType.Date }, ap);
        }

        #endregion

        public DataTable EditGetConf(int id_prog, string id_value, string value)
        {
            ap.Clear();
            ap.Add(id_prog);
            ap.Add(id_value);
            ap.Add(value);
            return executeProcedure("[Arenda].[EditGetConf]",
                new string[3] { "@id_prog", "@id_value", "@value" },
                new DbType[3] { DbType.Int32, DbType.String, DbType.String }, ap);
        }

        public DataTable getScan(int id_Doc, int id)
        {
            ap.Clear();
            ap.Add(id_Doc);
            ap.Add(id);

            return executeProcedure("[Arenda].[getScan]",
              new string[] { "@id_Doc", "@id" },
              new DbType[] { DbType.Int32, DbType.Int32 }, ap);
        }

        public DataTable GetMailProperty()
        {
            ap.Clear();

            return executeProcedure("[Arenda].[GetMailProperty]",
              new string[] { },
              new DbType[] { }, ap);
        }

        public DataTable UpdateDateSendLoadAccount1C(int id)
        {
            ap.Clear();
            ap.Add(id);

            return executeProcedure("[Arenda].[UpdateDateSendLoadAccount1C]",
              new string[1] { "@id" },
              new DbType[1] { DbType.Int32 }, ap);
        }
    }
}
