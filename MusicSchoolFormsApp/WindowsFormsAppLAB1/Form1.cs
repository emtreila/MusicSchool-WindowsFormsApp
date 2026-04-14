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

namespace WindowsFormsAppLAB1
{
    public partial class Form1 : Form
    {
        SqlConnection dbConn;
        SqlDataAdapter daStudents, daGrades;
        SqlCommandBuilder cb;
        DataSet ds;
        BindingSource bsStudents, bsGrades;
        public Form1()
        {
            InitializeComponent();
        }

        private void btnSaveData_Click(object sender, EventArgs e)
        {
            daGrades.Update(ds, "Grades");
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            dbConn = new SqlConnection("Server = EMTREILA-PC\\SQLEXPRESS ; dATABASE = MusicSchool; Integrated Security = true");

            ds = new DataSet();

            daStudents = new SqlDataAdapter("SELECT * FROM Students", dbConn);
            daGrades = new SqlDataAdapter("SELECT * FROM Grades", dbConn);
            cb = new SqlCommandBuilder(daGrades);

            daStudents.Fill(ds, "Students");
            daGrades.Fill(ds, "Grades");

            DataRelation dr = new DataRelation("FK_Grades_Students",
                                                ds.Tables["Students"].Columns["StudentID"],
                                                ds.Tables["Grades"].Columns["StudentID"]);
            ds.Relations.Add(dr);

            bsStudents = new BindingSource();
            bsStudents.DataSource = ds;
            bsStudents.DataMember = "Students";

            bsGrades = new BindingSource();
            bsGrades.DataSource = bsStudents;
            bsGrades.DataMember = "FK_Grades_Students";

            dgvT1.DataSource = bsStudents;
            dgvT2.DataSource = bsGrades;
        }
    }


}
