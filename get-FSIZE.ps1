function Get-FSize ()
{
  <#
  .SYNOPSIS
  Display Total Folder size
  .DESCRIPTION
  Describe the function in more detail
  .EXAMPLE
  Get-FSize 
   This will display a sum in MB of of the directory, including all folders and files.
  .EXAMPLE
  Get-Fsize -folderloc c:\users
  This will display a sum in MB of the directory that is specified @ -folderloc
  .PARAMETER folderloc
  The location of the directory to TOTAL
  #>
  [CmdletBinding()]   # Elevating to ADVANCED FUNCTION
  param (  # Define Parameter
         [Parameter( Mandatory = $false,
                     ValuefromPipeline=$true,
                     HelpMessage = 'Input folder location in filesystem'
                     )]
         [string[]] $folderloc = "$(pwd)"
        )  # End the parameter block

  begin { }

  process { ## Code the is excuted
            $startFolder = "$folderloc"

            $colItems = (Get-ChildItem $startFolder -ErrorAction SilentlyContinue -Recurse | Measure-Object -property length -sum)
            "$startFolder -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"
          }

  end { }

}