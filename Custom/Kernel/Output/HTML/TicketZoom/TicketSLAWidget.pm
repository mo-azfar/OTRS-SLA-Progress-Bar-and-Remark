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
			if ($ProgressPercent > 100)
			{
				$ProgressPercent = 100;
			}
			my $NewProgressPercent = $ProgressPercent.'%';
			$Ticket{FirstResponseTimeProgress} = $NewProgressPercent;
		}
		else
		{
			$Ticket{FirstResponseTimeProgress} = 'N/A';
		}
        #end progress bar
        
        #begin SLA first response time remark
        $Ticket{FirstResponseDiffInMin}      ||= 0;
		$Ticket{FirstResponseTimeEscalation} ||= 0;
		#my $TargetResponseTime;
        
		#First Response logic
		#If agent didnt yet response and current time is still below sla resposne time
		if( $Ticket{'FirstResponseDiffInMin'} eq 0 && $Ticket{'FirstResponseTimeEscalation'} eq 0)
		{
        $Ticket{FirstResponseTimeStatus}="Within";
        #$TargetResponseTime=$Ticket{FirstResponseTimeDestinationDate};
		}
		
		#If agent didnt yet response and current time is over sla resposne time
		if( $Ticket{'FirstResponseDiffInMin'} eq 0 && $Ticket{'FirstResponseTimeEscalation'} ne 0)
		{
		$Ticket{FirstResponseTimeStatus}="Breach";
		#$TargetResponseTime=$Ticket{FirstResponseTimeDestinationDate};
		}
		
		#If agent already response
		if( $Ticket{'FirstResponseDiffInMin'} ne 0 && $Ticket{'FirstResponseTimeEscalation'} eq 0)
		{
			my $DateTimeObject1 = $Kernel::OM->Create(
					'Kernel::System::DateTime',
					ObjectParams => {
					String   => $Ticket{FirstResponse},
					}
				);
				
			if ($Ticket{'FirstResponseDiffInMin'} < 0)
			{
				$Ticket{FirstResponseTimeStatus}="Breach";
				
				#my $Success = $DateTimeObject1->Subtract(
				#	Minutes       => abs($Ticket{FirstResponseDiffInMin}),
				#	AsWorkingTime => 1, # set to 1 to add given values as working time
				#);
                #
				#$TargetResponseTime = $DateTimeObject1->ToString();
					
			}
			else
			{
                $Ticket{FirstResponseTimeStatus}="Within";
				
				#my $Success = $DateTimeObject1->Add(
				#	Minutes       => $Ticket{FirstResponseDiffInMin},
				#	AsWorkingTime => 1, # set to 1 to add given values as working time
				#);
				#
				#$TargetResponseTime = $DateTimeObject1->ToString();
			
			}
		}
        #end SLA first response time remark
        
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
			if ($ProgressPercent > 100)
			{
				$ProgressPercent = 100;
			}
			my $NewProgressPercent = $ProgressPercent.'%';
			$Ticket{SolutionTimeProgress} = $NewProgressPercent;
		}
		else
		{
			$Ticket{SolutionTimeProgress} = 'N/A';
		}
		#end progress bar
        
        #begin SLA solution time remark
        $Ticket{SolutionDiffInMin}           ||= 0;
		$Ticket{SolutionTimeEscalation}      ||= 0;
		$Ticket{Closed}	||= 0;
        #my $TargetSolutionTime;
        
        #Solution logic
		#If agent didnt yet solved the ticket and current time is still below sla solution time
		if( $Ticket{'SolutionDiffInMin'} eq 0 && $Ticket{'SolutionTimeEscalation'} eq 0)
		{
        $Ticket{SolutionTimeStatus} = "Within";
		#$TargetSolutionTime = $Ticket{SolutionTimeDestinationDate};
		}
		
		#If agent didnt yet solved the ticket and current time is over sla solution time
		if( $Ticket{'SolutionDiffInMin'} eq 0 && $Ticket{'SolutionTimeEscalation'} ne 0)
		{
		$Ticket{SolutionTimeStatus} = "Breach";
		#$TargetSolutionTime = $Ticket{SolutionTimeDestinationDate};
		}
		
		#If agent already closed the ticket
		if( $Ticket{'SolutionDiffInMin'} ne 0 && $Ticket{'SolutionTimeEscalation'} eq 0)
		{
			my $DateTimeObject2 = $Kernel::OM->Create(
				'Kernel::System::DateTime',
				ObjectParams => {
				String   => $Ticket{Closed},
				}
			);
		
			if ($Ticket{'SolutionDiffInMin'} < 0)
			{
				$Ticket{SolutionTimeStatus} = "Breach";
				
				#my $Success2 = $DateTimeObject2->Subtract(
				#	Minutes       => abs($Ticket{SolutionDiffInMin}),
				#	AsWorkingTime => 1, # set to 1 to add given values as working time
				#);
                #
				#$TargetSolutionTime = $DateTimeObject2->ToString();
			}
			else
			{
				$Ticket{SolutionTimeStatus} = "Within";
				
				#my $Success2 = $DateTimeObject2->Add(
				#	Minutes       => $Ticket{SolutionDiffInMin},
				#	AsWorkingTime => 1, # set to 1 to add given values as working time
				#);
                #
				#$TargetSolutionTime = $DateTimeObject2->ToString();	
			}
		}
        #end SLA solution time remark
		
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
