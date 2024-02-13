function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.7
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Diagrammer.Microsoft.AD
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param
    (

    )

    begin {
    }

    process {
        Write-Verbose -Message ($translate.connectingDomain -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $ForestGroups = Get-ADForestInfo

                if ($ForestGroups) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-HTMLLabel -Label $ForestRoot -IconType "ForestRoot" -URLIcon $URLIcon -SubgraphLabel -IconWidth 50 -IconHeight 50) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = $translate.DiagramLabel ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                            # Dummy Node used for subgraph centering
                            Node CHILDDOMAINSTEXT @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'point'; fillColor = 'transparent' }
                            foreach ($ForestGroupOBJ in $ForestGroups) {
                                if ($ForestGroupOBJ.Name -match $ForestRoot -and $ForestGroupOBJ.Childs.Group) {
                                    $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                    SubGraph ContiguousChilds -Attributes @{Label = $translate.contiguous; fontsize = 20; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                        SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; fontcolor = "black" } {
                                            Node -Name "$($SubGraphName)DomainTable" -Attributes @{Label = (Get-HtmlTable -Rows $ForestGroupOBJ.Childs.Group -MultiColunms -Columnsize 3 -Align 'Center' -fontSize 14); shape = "plain"; fillColor = 'transparent' }
                                        }
                                    }
                                    Edge -From CHILDDOMAINSTEXT -To "$($SubGraphName)DomainTable" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                } elseif ($ForestGroupOBJ.Name -notmatch $ForestRoot -and $ForestGroupOBJ.Childs) {
                                    $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                    SubGraph NonContiguousChilds -Attributes @{Label = $translate.noncontiguous; fontsize = 20; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                        if ($ForestGroupOBJ.Childs.Group.Length -ge 1) {
                                            SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name "$($SubGraphName)DomainTable" -Attributes @{Label = (Get-HtmlTable -Rows $ForestGroupOBJ.Childs.Group -MultiColunms -Columnsize 3 -Align 'Center' -fontSize 14); shape = "plain"; fillColor = 'transparent' }
                                            }
                                        } else {
                                            $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name $ForestGroupOBJ.Name @{ Label = (Get-HtmlTable -Rows $ForestGroupOBJ.Name -MultiColunms -Columnsize 3 -Align 'Center' -fontSize 14); shape = 'plain'; fillColor = 'transparent' }
                                            }
                                        }
                                    }
                                    if ($ForestGroupOBJ.Childs.Group.Length -ge 1) {
                                        Edge -From CHILDDOMAINSTEXT -To "$($SubGraphName)DomainTable" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    } else {
                                        Edge -From CHILDDOMAINSTEXT -To $ForestGroupOBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }

                                } else {
                                    Node -Name NoChildDomain @{LAbel = $translate.NoChildDomain; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                                }
                            }

                        }
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}