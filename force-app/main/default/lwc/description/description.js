import { LightningElement } from 'lwc';
export default class Description extends LightningElement {
    handleFinish() {
        window.history.back();
    }
}
