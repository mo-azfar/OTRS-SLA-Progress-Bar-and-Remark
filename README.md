# OTRS-SLA-Progress-Bar-and-Remark
- For OTRS CE v6.0
- Display SLA Progress Bar and Its Remark (Breach or Within SLA) at Ticket Zoom Screen 

1. Only for First Response Time and Solution Time.  

2. 	When SLA Progress < 50%, green bar  
	When SLA Progress >= 50%, yellow bar  
	When SLA Progress >= 100%, red bar  
	  
3. Update progress bar css at CSS$OTRS_HOME/var/httpd/htdocs/skins/Agent/default/css/Core.PageLayout.css  

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
				    background-color: #fefefe;
				    border-radius: 3px;
				    transition: width 500ms ease-in-out;
				}
				    
				.progress-bar-fill-green {
				    display: block;
				    height: 12px;
				    background-color: #64ff56;
				    border-radius: 3px;
				    transition: width 500ms ease-in-out;
				}
				
				.progress-bar-fill-yellow {
				    display: block;
				    height: 12px;
				    background-color: #f8ff56;
				    border-radius: 3px;
				    transition: width 500ms ease-in-out;
				}
				
				.progress-bar-fill-red {
				    display: block;
				    height: 12px;
				    background-color: #f64242;
				    border-radius: 3px;
				    transition: width 500ms ease-in-out;
				}


[![pb1.png](https://i.postimg.cc/26q9D2bB/pb1.png)](https://postimg.cc/7Gkn11Nx)  
  
[![pb2.png](https://i.postimg.cc/ZKz7GPTC/pb2.png)](https://postimg.cc/BtNBDKP0)  
