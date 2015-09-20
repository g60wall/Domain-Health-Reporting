[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition
 
# chart object
   $chart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
   $chart1.Width = 600
   $chart1.Height = 600
   $chart1.BackColor = [System.Drawing.Color]::White
 
# title 
   [void]$chart1.Titles.Add("Top 5 - Memory Usage (as: Column)")
   $chart1.Titles[0].Font = "Arial,13pt"
   $chart1.Titles[0].Alignment = "topLeft"
 
# chart area 
   $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
   $chartarea.Name = "ChartArea1"
   $chartarea.AxisY.Title = "Memory (MB)"
   $chartarea.AxisX.Title = "Process Name"
   $chartarea.AxisY.Interval = 100
   $chartarea.AxisX.Interval = 1
   $chart1.ChartAreas.Add($chartarea)
 
# legend 
   $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
   $legend.name = "Legend1"
   $chart1.Legends.Add($legend)
 
# data source
   $datasource = Get-Process | sort PrivateMemorySize -Descending  | Select-Object -First 10
 
# data series
   [void]$chart1.Series.Add("VirtualMem")
   $chart1.Series["VirtualMem"].ChartType = "Column"
   $chart1.Series["VirtualMem"].BorderWidth  = 3
   $chart1.Series["VirtualMem"].IsVisibleInLegend = $true
   $chart1.Series["VirtualMem"].chartarea = "ChartArea1"
   $chart1.Series["VirtualMem"].Legend = "Legend1"
   $chart1.Series["VirtualMem"].color = "#62B5CC"
   $datasource | ForEach-Object {$chart1.Series["VirtualMem"].Points.addxy( $_.Name , ($_.VirtualMemorySize / 1000000)) }
 
# data series
   [void]$chart1.Series.Add("PrivateMem")
   $chart1.Series["PrivateMem"].ChartType = "Column"
   $chart1.Series["PrivateMem"].IsVisibleInLegend = $true
   $chart1.Series["PrivateMem"].BorderWidth  = 3
   $chart1.Series["PrivateMem"].chartarea = "ChartArea1"
   $chart1.Series["PrivateMem"].Legend = "Legend1"
   $chart1.Series["PrivateMem"].color = "#E3B64C"
   $datasource | ForEach-Object {$chart1.Series["PrivateMem"].Points.addxy( $_.Name , ($_.PrivateMemorySize / 1000000)) }
 
# save chart
   $chart1.SaveImage("$scriptpath\SplineArea.png","png")
 