using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Configuration;

namespace WindowsFormsAppLAB1
{
    public partial class Form1 : Form
    {
        SqlConnection dbConn;
        SqlDataAdapter daParent, daChild;
        SqlCommandBuilder cb;
        DataSet ds;
        BindingSource bsParent, bsChild;

        string parentTable, childTable, relationName;
        public Form1()
        {
            InitializeComponent();
        }

        private void btnReloadData_Click(object sender, EventArgs e)
        {
            ds.Clear();
            daParent.Fill(ds, parentTable);
            daChild.Fill(ds, childTable);
        }


        private void btnSaveData_Click(object sender, EventArgs e)
        {
            daChild.Update(ds, childTable);
        }

        private void Form1_Load(object sender, EventArgs e)
        {

            string connStr = ConfigurationManager.AppSettings["ConnectionString"];
            string formCaption = ConfigurationManager.AppSettings["FormCaption"];

            parentTable = ConfigurationManager.AppSettings["ParentTable"];
            string parentQuery = ConfigurationManager.AppSettings["ParentQuery"];
            string parentLabel = ConfigurationManager.AppSettings["ParentLabel"];
            string parentKey = ConfigurationManager.AppSettings["ParentKey"];

            childTable = ConfigurationManager.AppSettings["ChildTable"];
            string childQuery = ConfigurationManager.AppSettings["ChildQuery"];
            string childLabel = ConfigurationManager.AppSettings["ChildLabel"];
            string childKey = ConfigurationManager.AppSettings["ChildKey"];

            relationName = ConfigurationManager.AppSettings["RelationName"];

            this.Text = formCaption;
            this.parentLabel.Text = parentLabel;
            this.childLabel.Text = childLabel;

            dbConn = new SqlConnection(connStr);
            ds = new DataSet();

            daParent = new SqlDataAdapter(parentQuery, dbConn);
            daChild = new SqlDataAdapter(childQuery, dbConn);
            
            cb = new SqlCommandBuilder(daChild);

            daParent.Fill(ds, parentTable);
            daChild.Fill(ds, childTable);

            DataRelation dr = new DataRelation(relationName,
                                                ds.Tables[parentTable].Columns[parentKey],
                                                ds.Tables[childTable].Columns[childKey]);
            ds.Relations.Add(dr);

            bsParent = new BindingSource();
            bsParent.DataSource = ds;
            bsParent.DataMember = parentTable;

            bsChild = new BindingSource();
            bsChild.DataSource = bsParent;
            bsChild.DataMember = relationName;

            dgvStudents.DataSource = bsParent;
            dgvGrades.DataSource = bsChild;

        }
    }


}
