namespace WindowsFormsAppLAB1
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.dgvStudents = new System.Windows.Forms.DataGridView();
            this.dgvGrades = new System.Windows.Forms.DataGridView();
            this.btnSaveData = new System.Windows.Forms.Button();
            this.childLabel = new System.Windows.Forms.Label();
            this.btnReloadData = new System.Windows.Forms.Button();
            this.parentLabel = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dgvStudents)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvGrades)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvStudents
            // 
            this.dgvStudents.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvStudents.Location = new System.Drawing.Point(136, 31);
            this.dgvStudents.Name = "dgvStudents";
            this.dgvStudents.RowHeadersWidth = 51;
            this.dgvStudents.RowTemplate.Height = 24;
            this.dgvStudents.Size = new System.Drawing.Size(623, 222);
            this.dgvStudents.TabIndex = 0;
            // 
            // dgvGrades
            // 
            this.dgvGrades.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvGrades.Location = new System.Drawing.Point(136, 271);
            this.dgvGrades.Name = "dgvGrades";
            this.dgvGrades.RowHeadersWidth = 51;
            this.dgvGrades.RowTemplate.Height = 24;
            this.dgvGrades.Size = new System.Drawing.Size(623, 223);
            this.dgvGrades.TabIndex = 1;
            // 
            // btnSaveData
            // 
            this.btnSaveData.Location = new System.Drawing.Point(842, 161);
            this.btnSaveData.Name = "btnSaveData";
            this.btnSaveData.Size = new System.Drawing.Size(85, 41);
            this.btnSaveData.TabIndex = 2;
            this.btnSaveData.Text = "Save data";
            this.btnSaveData.UseVisualStyleBackColor = true;
            this.btnSaveData.Click += new System.EventHandler(this.btnSaveData_Click);
            // 
            // childLabel
            // 
            this.childLabel.AutoSize = true;
            this.childLabel.Location = new System.Drawing.Point(35, 300);
            this.childLabel.Name = "childLabel";
            this.childLabel.Size = new System.Drawing.Size(73, 16);
            this.childLabel.TabIndex = 4;
            this.childLabel.Text = "Child table:";
            // 
            // btnReloadData
            // 
            this.btnReloadData.Location = new System.Drawing.Point(858, 286);
            this.btnReloadData.Name = "btnReloadData";
            this.btnReloadData.Size = new System.Drawing.Size(75, 23);
            this.btnReloadData.TabIndex = 5;
            this.btnReloadData.Text = "Reload data";
            this.btnReloadData.UseVisualStyleBackColor = true;
            this.btnReloadData.Click += new System.EventHandler(this.btnReloadData_Click);
            // 
            // parentLabel
            // 
            this.parentLabel.AutoSize = true;
            this.parentLabel.Location = new System.Drawing.Point(38, 60);
            this.parentLabel.Name = "parentLabel";
            this.parentLabel.Size = new System.Drawing.Size(82, 16);
            this.parentLabel.TabIndex = 6;
            this.parentLabel.Text = "Parent table:";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(973, 506);
            this.Controls.Add(this.parentLabel);
            this.Controls.Add(this.btnReloadData);
            this.Controls.Add(this.childLabel);
            this.Controls.Add(this.btnSaveData);
            this.Controls.Add(this.dgvGrades);
            this.Controls.Add(this.dgvStudents);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgvStudents)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvGrades)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvStudents;
        private System.Windows.Forms.DataGridView dgvGrades;
        private System.Windows.Forms.Button btnSaveData;
        private System.Windows.Forms.Label childLabel;
        private System.Windows.Forms.Button btnReloadData;
        private System.Windows.Forms.Label parentLabel;
    }
}

