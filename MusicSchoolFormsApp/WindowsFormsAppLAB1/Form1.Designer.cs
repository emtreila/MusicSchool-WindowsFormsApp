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
            this.dgvT1 = new System.Windows.Forms.DataGridView();
            this.dgvT2 = new System.Windows.Forms.DataGridView();
            this.btnSaveData = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dgvT1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvT2)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvT1
            // 
            this.dgvT1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvT1.Location = new System.Drawing.Point(29, 12);
            this.dgvT1.Name = "dgvT1";
            this.dgvT1.RowTemplate.Height = 24;
            this.dgvT1.Size = new System.Drawing.Size(623, 222);
            this.dgvT1.TabIndex = 0;
            // 
            // dgvT2
            // 
            this.dgvT2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvT2.Location = new System.Drawing.Point(29, 258);
            this.dgvT2.Name = "dgvT2";
            this.dgvT2.RowTemplate.Height = 24;
            this.dgvT2.Size = new System.Drawing.Size(623, 223);
            this.dgvT2.TabIndex = 1;
            // 
            // btnSaveData
            // 
            this.btnSaveData.Location = new System.Drawing.Point(693, 225);
            this.btnSaveData.Name = "btnSaveData";
            this.btnSaveData.Size = new System.Drawing.Size(85, 41);
            this.btnSaveData.TabIndex = 2;
            this.btnSaveData.Text = "Save data";
            this.btnSaveData.UseVisualStyleBackColor = true;
            this.btnSaveData.Click += new System.EventHandler(this.btnSaveData_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(825, 506);
            this.Controls.Add(this.btnSaveData);
            this.Controls.Add(this.dgvT2);
            this.Controls.Add(this.dgvT1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgvT1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvT2)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvT1;
        private System.Windows.Forms.DataGridView dgvT2;
        private System.Windows.Forms.Button btnSaveData;
    }
}

