# --
# Copyright (C) 2022 mo-azfar, https://github.com/mo-azfar/OTRS-SLA-Progress-Bar-and-Remark
#
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
	#my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
	
	my %Ticket    = %{ $Param{Ticket} };
    my %AclAction = %{ $Param{AclAction} };
	
	$Ticket{FirstResponseDiffInMin}      ||= 0;  #if ticket responded by agent, how many minute taken by agent to response (+ within sla, - breach sla)
	$Ticket{FirstResponseTimeEscalation} ||= 0;  #if ticket not yet respond, value is 0 (current time still within sla) OR 1 (current time is over sla)
	$Ticket{FirstResponseTimeNotification} ||=0; #if true (1), notify - x% of escalation has reached
	
	$Ticket{SolutionDiffInMin}           ||= 0;  #if ticket close by agent, how many minute taken by agent to close it (+ within sla, - breach sla)
	$Ticket{SolutionTimeEscalation}      ||= 0; #if ticket not yet close, value is 0 (current time still within sla) OR 1 (current time is over sla)
	$Ticket{SolutionTimeNotification}    ||= 0; #if true (1), notify - x% of escalation has reached
	
	$Ticket{FirstResponseTimeProgress} = "N/A";
	$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill";
	
	$Ticket{SolutionTimeProgress} = "N/A";
	$Ticket{SolutionTimeProgressClass} = "progress-bar-fill";
	
	#create based time object
	my $CreatedTimeObject = $Kernel::OM->Create(
	'Kernel::System::DateTime',
		ObjectParams => {
			String   => $Ticket{Created},
						}
	);
		
	my $CurrentTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
	my $Epoch1 = $CreatedTimeObject->ToEpoch();
	my $Epoch2 = $CurrentTimeObject->ToEpoch();
				
	#First Response logic
	if (defined $Ticket{FirstResponseTime} || $Ticket{FirstResponseDiffInMin} ne 0 || $Ticket{FirstResponseTimeEscalation} ne 0 )
	{	
		my $ProgressPercent;
		if( $Ticket{'FirstResponseDiffInMin'} eq 0 )  #If agent didnt yet response 
		{			
			if ( $Ticket{'FirstResponseTimeEscalation'} eq 0 ) #current time is still below sla response time
			{
				my $Epoch3 = $Ticket{FirstResponseTimeDestinationTime};
				my $Progress = (($Epoch2-$Epoch1)/($Epoch3-$Epoch1)) * 100;
				$ProgressPercent = sprintf('%.2f', $Progress);
							
				if ($Ticket{'FirstResponseTimeNotification'} eq 1) #if value notify before is 1 (almost overdue x% sla time)
				{
					$Ticket{FirstResponseTimeStatus} = "Within (Notify Before)";
					$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-yellow";
					$Ticket{FirstResponseTimeProgress} = $ProgressPercent.'%';
				}
				else
				{
					$Ticket{FirstResponseTimeStatus} = "Within";
					$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-green";
					$Ticket{FirstResponseTimeProgress} = $ProgressPercent.'%';
				}				
			}
			else #current time is over sla response time
			{
				$Ticket{FirstResponseTimeStatus} = "Breach";
				$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-red";
				$Ticket{FirstResponseTimeProgress} = "100%";
				
			}
			
		}
		else #If agent already response
		{
			if ($Ticket{'FirstResponseDiffInMin'} =~/^\-/) #value negative or overdue sla
			{
				$Ticket{FirstResponseTimeStatus} = "Breach";
				$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-red";
			}
			else
			{				
				$Ticket{FirstResponseTimeStatus} = "Within";
				$Ticket{FirstResponseTimeProgressClass} = "progress-bar-fill-green";
			}	
		}
			
		$LayoutObject->Block(
            Name => 'FirstResponseTimeRemark',
            Data => { %Ticket, %AclAction },
        );
	}
	
	#Solution logic
	if (defined $Ticket{SolutionTime} || $Ticket{SolutionDiffInMin} ne 0 || $Ticket{SolutionTimeEscalation} ne 0 )
	{	
		my $ProgressPercent;
		if( $Ticket{'SolutionDiffInMin'} eq 0 )  #If agent didnt yet close
		{			
			if ( $Ticket{'SolutionTimeEscalation'} eq 0 ) #current time is still below sla solution time
			{
				my $Epoch3 = $Ticket{SolutionTimeDestinationTime};
				my $Progress = (($Epoch2-$Epoch1)/($Epoch3-$Epoch1)) * 100;
				$ProgressPercent = sprintf('%.2f', $Progress);
							
				if ($Ticket{'SolutionTimeNotification'} eq 1) #if value notify before is 1 (almost overdue x% sla time)
				{
					$Ticket{SolutionTimeStatus} = "Within (Notify Before)";
					$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-yellow";
					$Ticket{SolutionTimeProgress} = $ProgressPercent.'%';
				}
				else
				{
					$Ticket{SolutionTimeStatus} = "Within";
					$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-green";
					$Ticket{SolutionTimeProgress} = $ProgressPercent.'%';
				}				
			}
			else #current time is over sla solution time
			{
				$Ticket{SolutionTimeStatus} = "Breach";
				$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-red";
				$Ticket{SolutionTimeProgress} = "100%";
				
			}
			
		}
		else #If agent already solution
		{
			if ($Ticket{'SolutionDiffInMin'} =~/^\-/) #value negative or overdue sla
			{
				$Ticket{SolutionTimeStatus} = "Breach";
				$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-red";
			}
			else
			{				
				$Ticket{SolutionTimeStatus} = "Within";
				$Ticket{SolutionTimeProgressClass} = "progress-bar-fill-green";
			}	
		}
			
		$LayoutObject->Block(
            Name => 'SolutionTimeRemark',
            Data => { %Ticket, %AclAction },
        );
	}
	
    # set display options
    $Param{WidgetTitle} = Translatable('SLA Progress Bar');
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
