/**
 * @description       : Removes some basic tags from string
 * @author            : Siddharth Patni
 * @last modified on  : 09-29-2021
 * @last modified by  : Siddharth Patni
**/
public class HTMLTags {
    public static String removeTags(String message) {
        
        return message.replaceAll('<p>', '').replaceAll('</p>', '').replaceAll('<a>', '').replaceAll('</a>', '').replaceAll('<b>', '').replaceAll('</b>', '').replaceAll('<i>', '').replaceAll('</i>', '').replaceAll('<u>', '').replaceAll('<s>', '').replaceAll('</s>', '').replaceAll('<ul>', '').replaceAll('</ul>', '').replaceAll('<ol>', '').replaceAll('</ol>', '').replaceAll('<li>', '').replaceAll('</li>', '');         
        
    }
}
