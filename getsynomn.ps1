Function Get-Synonym()
{
# Parameter Definition

Param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
      
      If($_ -match "^[a-zA-Z]+$"){
      $True
      }
      else{
      Throw "$_ is not a valid Word or contains something beyond Alphabets A-Z or a-z"
      }
    })
    ] $Word
     )

Try
{

# Capturing XML data by requesting the URL

    $webpage = Invoke-WebRequest -Uri "http://thesaurus.altervista.org/thesaurus/v1?word=$Word&key=qFTNpXBBp8xiNR0LdGCt&language=en_US" -UseBasicParsing -ErrorVariable ErrVar
    
    $Word = (Get-Culture).textinfo.totitlecase($Word)
    $content = $webpage.Content
    
# Data Mining

    $Category = (Select-Xml -content $content -xpath '//list/category').node.InnerText
    $Category = $Category | %{$str=$_;(Get-Culture).textinfo.totitlecase($str.Substring(1,$str.Length-2))}
    $Data = ((Select-Xml -content $content -xpath '//list/synonyms').node.InnerText)
    
       $Object = @()
    
    if($Category.count -gt 1)
    {
        For($i=0;$i -lt $($Category.Count);$i++)
        {
        $synonyms = (Get-Culture).textinfo.totitlecase($Data[$i]).Split('|')
        
            For($j=0;$j -lt $($synonyms.Count);$j++)
            {
        
                $Object += New-Object psobject -Property @{Word=$Word;Category=Get-FullWord($Category[$i]);Synonym=$synonyms[$j]}
            }
        }
        
            Return $Object
    }
    else
    {
    
    $synonyms = (Get-Culture).textinfo.totitlecase($Data).Split('|')
        For($j=0;$j -lt $($synonyms.Count);$j++)
        {
    
            $Object += New-Object psobject -Property @{Word=$Word;Category=Get-FullWord($Category);Synonym=$synonyms[$j]}
    
        }

            Return $Object
    }

}
catch
{
    Write-Host $_.exception.message -ForegroundColor Yellow
}

}


# Function to Change Abbreviations to Full Forms
Function Get-FullWord ($Abbreviation)
{
        $Table = @{
                        "Adj"="Adjective"
                        "Adv"="Adverb"
                  }

         $FullWord=$Table | %{ if($_.containskey($Abbreviation)){$_.get_item($Abbreviation)}else{$Abbreviation}  }

         Return $FullWord
}

