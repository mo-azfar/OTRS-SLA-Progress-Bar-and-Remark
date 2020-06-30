# OTRS-SLA-Progress-Bar-and-Remark
- For OTRS CE v6.0
- Display SLA Progress Bar and Its Remark (Breach or Within SLA) at Ticket Zoom Screen 

1. Only for First Response Time and Solution Time.  

2. Update progress bar css at CSS$OTRS_HOME/var/httpd/htdocs/skins/Agent/default/css/Core.PageLayout.css  

				.progress-bar {
					width: 100%;
					background-color: #e0e0e0;
					padding: 3px;
					border-radius: 3px;
					box-shadow: inset 0 1px 3px rgba(0, 0, 0, .2);
				}
							
				.progress-bar-fill {
					display: block;
					height: 12px;
					background-color: #659cef;
					border-radius: 3px;
					transition: width 500ms ease-in-out;
				}


[![pb.png](https://i.postimg.cc/tJxp0Xp0/pb.png)](https://postimg.cc/YLMJYBv8)

