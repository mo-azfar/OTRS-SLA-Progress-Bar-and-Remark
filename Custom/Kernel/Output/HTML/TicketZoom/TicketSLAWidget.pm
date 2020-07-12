# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::TicketZoom::TicketSLAWidget;

use parent 'Kernel::Output::HTML::Base';

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(IsHashRefWithData);

our $ObjectManagerDisabled = 1;

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
	
	my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );
	my %Ticket = $TicketObject->TicketGet(
        TicketID => $TicketID,
		UserID        => 1,
		DynamicFields => 0,
		Extended => 1,
    );
	
    #my %Ticket    = %{ $Param{Ticket} };
    my %AclAction = %{ $Param{AclAction} };

    # show first response time if needed
    if ( defined $Ticket{FirstResponseTime} || defined $Ticket{FirstResponseDiffInMin} || defined $Ticket{FirstResponseTimeEscalation} ) {
        
		#begin progress bar
		if ( defined $Ticket{FirstResponseTime} )
		{
			my $CreatedTimeObject = $Kernel::OM->Create(
				'Kernel::System::DateTime',
					ObjectParams => {
						String   => $Ticket{Created},
									}
			);
        
			my $CurrentTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
			my $Epoch1 = $CreatedTimeObject->ToEpoch();
			my $Epoch2 = $CurrentTimeObject->ToEpoch();
			my $Epoch3 = $Ticket{FirstResponseTimeDestinationTime};
			my $Progress = (($Epoch2-$Epoch1)/($Epoch3-$Epoch1)) * 100;
			my $ProgressPercent = sprintf('%.2f', $Progress);
			if ($ProgressPercent < 50)
			{
				$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-green";
			}
			elsif (($ProgressPercent > 49) && ($ProgressPercent < 100))
			{
				$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-yellow";
			}
			else
			{
				$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-red";
				$ProgressPercent = 100;
			}
			my $NewProgressPercent = $ProgressPercent.'%';
			$Ticket{FirstResponseTimeProgress} = $NewProgressPercent;
		}
		else
		{
			$Ticket{FirstResponseTimeProgress} = 'N/A';
			$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill";
		}
        #end progress bar
        
        #begin SLA first response time remark
        $Ticket{FirstResponseDiffInMin}      ||= 0;
		$Ticket{FirstResponseTimeEscalation} ||= 0;
		#my $TargetResponseTime;
        
		#First Response logic
		#If agent didnt yet response 
        if( $Ticket{'FirstResponseDiffInMin'} eq 0 )
        {
            if ( $Ticket{'FirstResponseTimeEscalation'} eq 0 ) #current time is still below sla response time
            {
                $Ticket{FirstResponseTimeStatus}="Within";
            }
            else #current time is over sla response time
            {
                $Ticket{FirstResponseTimeStatus}="Breach";
            }
        }
        else #If agent already response
        {
            if ($Ticket{'FirstResponseDiffInMin'} =~/^\-/) #value negative
            {
                $Ticket{FirstResponseTimeStatus}="Breach";
            }
            else
            {
                $Ticket{FirstResponseTimeStatus}="Within";
            }
        }
        
        $LayoutObject->Block(
            Name => 'FirstResponseTimeRemark',
            Data => { %Ticket, %AclAction },
        );
        
    }

    # show solution time if needed
	if ( defined $Ticket{SolutionTime} || defined $Ticket{SolutionDiffInMin} || defined $Ticket{SolutionTimeEscalation} ) {
        
		#begin progress bar
		if ( defined $Ticket{SolutionTime} )
		{
			my $CreatedTimeObject = $Kernel::OM->Create(
				'Kernel::System::DateTime',
					ObjectParams => {
						String   => $Ticket{Created},
									}
			);
        
			my $CurrentTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
			my $Epoch1 = $CreatedTimeObject->ToEpoch();
			my $Epoch2 = $CurrentTimeObject->ToEpoch();
			my $Epoch3 = $Ticket{SolutionTimeDestinationTime};
			my $Progress = (($Epoch2-$Epoch1)/($Epoch3-$Epoch1)) * 100;
			my $ProgressPercent = sprintf('%.2f', $Progress);
			if ($ProgressPercent < 50)
			{
				$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-green";
			}
			elsif (($ProgressPercent > 49) && ($ProgressPercent < 100))
			{
				$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-yellow";
			}
			else
			{
				$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-red";
				$ProgressPercent = 100;
			}
			
			my $NewProgressPercent = $ProgressPercent.'%';
			$Ticket{SolutionTimeProgress} = $NewProgressPercent;
		}
		else
		{
			$Ticket{SolutionTimeProgress} = 'N/A';
			$Ticket{SolutionTimeProgressClass} = "progress-bar-fill";
		}
		#end progress bar
        
        #begin SLA solution time remark
        $Ticket{SolutionDiffInMin}           ||= 0;
		$Ticket{SolutionTimeEscalation}      ||= 0;
		$Ticket{Closed}	||= 0;
        #my $TargetSolutionTime;
        
        #Solution logic
		 #If agent didnt yet solved the ticket 
        if( $Ticket{'SolutionDiffInMin'} eq 0 )
        {
            if ( $Ticket{'SolutionTimeEscalation'} eq 0 ) #current time is still below sla solution time
            {
                $Ticket{SolutionTimeStatus}="Within";
            }
            else #current time over sla solution time
            {
                $Ticket{SolutionTimeStatus}="Breach";
            }
        }
        else #If agent already solve
        {
            if( $Ticket{'SolutionDiffInMin'} =~/^\-/ ) #value negative
            {
                $Ticket{SolutionTimeStatus}="Breach";
            }
            else
            {
                $Ticket{SolutionTimeStatus}="Within";
            }
            
        }
		
        $LayoutObject->Block(
            Name => 'SolutionTimeRemark',
            Data => { %Ticket, %AclAction },
        );
    }

    # set display options
    $Param{WidgetTitle} = Translatable('SLA Information');
    $Param{Hook}        = $ConfigObject->Get('Ticket::Hook') || 'Ticket#';

    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentTicketZoom/TicketSLAWidget',
        Data         => { %Param, %Ticket, %AclAction },
    );

    return {
        Output => $Output,
    };
}

1;
