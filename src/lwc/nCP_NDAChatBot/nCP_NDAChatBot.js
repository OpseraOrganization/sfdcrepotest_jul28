/**********************************************************************************************************************
* Date          Modified By         Remarks
* 27/01/2021    Soham               Created - To enable the NDA Chat Bot for Customer Portal. This is developed as 
                                    part of DEM0053592 - Enabling the NDA Chat Bot
***********************************************************************************************************************/
import { LightningElement, track } from 'lwc';
// Import custom labels
import ndaChatBotURL from '@salesforce/label/c.NCP_NDAChatbotURL';
//Import Static Resource
import NDAIMAGE from '@salesforce/resourceUrl/NDAChatbotFolder';
import isRenderedFlag from '@salesforce/apex/NCP_NDAChatBotController.isRendered';

export default class NCP_NDAChatBot extends LightningElement {
    @track isRendered;
    @track error;
    @track resourcePath = NDAIMAGE + '/NDAChatbot/ndachatbot.png';

    openForm() {
        console.log('Called Open Form');
        this.template.querySelector('div').style.display = "block";
        this.template.querySelector('button').style.display = "none";
    }
        
    closeForm() {
        console.log('Called Close Form');
        this.template.querySelector('div').style.display = "none";
        this.template.querySelector('button').style.display = "block";
    }

    get fullUrl() {
        //return 'https://staging.digital-assistant.nokia.com/conversation?botId=106';
        return ndaChatBotURL;
    }   

    connectedCallback(){
        isRenderedFlag()
        .then(result => {
            this.isRendered = result;
            console.log('this.isRendered: ', this.isRendered);
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.isRendered = undefined;
        });
   }
}