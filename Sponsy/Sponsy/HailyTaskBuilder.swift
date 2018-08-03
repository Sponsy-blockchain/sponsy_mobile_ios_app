//
//  HailyTaskBuilder.swift
//  Haily
//
//  Created by Admin on 06.01.17.
//  Copyright © 2017 Vanoproduction. All rights reserved.
//

import UIKit


class HailyTaskBuilder {
    
    let TOTAL_PIXABAY_SEARCH_ATTEMPTS:Int = 3
    
    var request_dict:NSMutableDictionary!
    var tasks:[HailyTask] = []
    var error = false
    var session:URLSession!
    
    init(session:URLSession, anonymous:Bool, degradePossible:Bool) {
        self.session = session
        request_dict = NSMutableDictionary()
    }
    
    
    func addTasks(_ tasks:[HailyTask]) {
        self.tasks.append(contentsOf: tasks)
    }
    
    func loadS3FileWithPath(_ path:String, completionHandler:@escaping ((_ data:Data?, _ error:Error?) -> Void)) {
        let data_task = session.dataTask(with: URL.init(string: "\(General.images_bucket_address)\(path)")!, completionHandler: {
            (data:Data?,url_response:URLResponse?,error:Error?) in
            if let _err = error {
                DispatchQueue.main.async(execute: {
                    completionHandler(nil, _err)
                })
            }
            else {
                if let _data = data {
                    DispatchQueue.main.async(execute: {
                        completionHandler(_data,nil)
                    })
                }
                else {
                    DispatchQueue.main.async(execute: {
                        completionHandler(nil,HailyError.InternalError("Error. No response data in loading S3 file"))
                    })
                }
            }
        })
        data_task.resume()
    }
    
    func sendTasksWithCompletionHandler(_ handler:@escaping ((_ parsedResponse:[HailyParsedResponse]?,_ error:Error?) -> Void)) {
        /*
        if General.authorized {
            if let feelingsTask = General.prepareFeelingsUpdateTask() {
                if let authToken = UserDefaults().string(forKey: "auth_token") {
                    request_dict["token"] = authToken
                    tasks.append(feelingsTask)
                    print("Adding feelings update task to another request")
                }
            }
        }
 */
        var tasks_array:[NSDictionary] = []
        var auth_required = false
        for task in tasks {
            if task is HailyReceiveTask {
                let receive_task = task as! HailyReceiveTask
                if receive_task.dataType == HailyDataType.own || receive_task.dataOrigin == HailyDataOrigin.request {
                    auth_required = true
                }
            }
            else if task is HailySyncTask || task is HailySuggestionTask || task is HailyVoteTask || task is HailyPutForVotingTask {
                auth_required = true
            }
            let task_dict = NSMutableDictionary.init(dictionary: task.getDictionaryRepresentation())
            tasks_array.append(task_dict)
        }
        if auth_required {
            if let authToken = UserDefaults().string(forKey: "auth_token") {
                request_dict["auth_token"] = authToken
            }
        }
        request_dict["tasks"] = tasks_array
        print("having request data")
        print(request_dict)
        let request_json_data = try? JSONSerialization.data(withJSONObject: request_dict, options: [])
        if request_json_data == nil {
            error = true
        }
        if error {
          //  dispatch_async(dispatch_get_main_queue(), {
                handler(nil, NSError(domain: "HailyTaskBuilderError", code: 911, userInfo: nil))
           // })
        }
        else {
            let request_json_string = NSString(data: request_json_data!, encoding: String.Encoding.utf8.rawValue)!
            let final_request_string = "data=" + (request_json_string as String)
            let final_request_data = final_request_string.data(using: String.Encoding.utf8)!
            let task_url = URL(string: "\(General.online_address!)Receiver")!
            let task_request = NSMutableURLRequest(url: task_url)
            task_request.httpMethod = "POST"
            task_request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //task_request.httpBody = final_request_data
            task_request.httpBody = request_json_data!
            let dataTask = session.dataTask(with: task_request as URLRequest, completionHandler: {
                (data:Data?, response: URLResponse?, error:Error?) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
                if let _err = error {
                 //   dispatch_async(dispatch_get_main_queue(), {
                        handler(nil, _err)
                   // })
                }
                else {
                    let response_dict = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? NSDictionary
                    if let response = response_dict {
                        if let fatalDescription = response["errorFatal"] as? String {
                           // dispatch_async(dispatch_get_main_queue(), {
                            
                                handler(nil,HailyError.InternalError("Error: server fatal error response"))
                           // })
                        }
                        else {
                            let responses_unparsed = response["answers"] as! [NSDictionary]
                            let responses_parsed = HailyResponseParser.parseResponses(responses_unparsed, tasks: self.tasks)
                            if let _parsed = responses_parsed {
                            //    dispatch_async(dispatch_get_main_queue(), {
                                    handler(_parsed, nil)
                            //    })
                            }
                            else {
                             //   dispatch_async(dispatch_get_main_queue(), {
                                    handler(nil, HailyError.InternalError("Error: No parsed response"))
                            //    })
                            }
                        }
                    }
                    else {
                      //  dispatch_async(dispatch_get_main_queue(), {
                            handler(nil, HailyError.InternalError("Error: No response dictionary!"))
                      //  })
                    }
                }
            })
            dataTask.resume()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
}

enum ImageSearchApi {
    case Pixplorer, Pixabay
}

class HailyParsedResponse {
    
    var task:HailyTask!
    var unread:Bool?
    //create topic response
    var result:HailyResponseResult? = nil
    var sponsors:[HailyInjectable]?
    var events:[HailyInjectable]?
    var votings:[SponsyVote]?
    var requests:[SponsyRequest]?
    var eventDataDetailed:SponsyEventDetailed?
    var sponsorDataDetailed:SponsySponsorDetailed?
    var authError = false
    //receive task response
    var error:String? = nil
    var dataEnd = false
    //sync task response
    var newMessagesArrived:Bool?
    var message:String? = nil
    //sent with trending topics && opinions
    var lastValue:Double? = nil
    //sent with registration
    var loginResult:HailyLoginResult?
    var registerResult:HailyRegisterResult?
    
    init(responseTask:HailyTask) {
        task = responseTask
    }
    
}

class HailyResponseParser {
    
    class func parseResponses(_ responses:[NSDictionary],tasks:[HailyTask]) -> [HailyParsedResponse]? {
        if responses.count != tasks.count {
            print("ERROR: responses amount is not equal to tasks amount! Terminating")
            return nil
        }
        var responsesParsed:[HailyParsedResponse] = []
        for i in 0 ..< responses.count {
            let requestTask = tasks[i]
            let parsedResponse = HailyParsedResponse(responseTask: requestTask)
            switch requestTask {
            case is HailyReceiveTask:
                if let _error = responses[i]["error"] as? String {
                    parsedResponse.error = _error
                }
                if let _unread = responses[i]["unread"] as? Bool {
                    parsedResponse.unread = _unread
                }
                if let events = responses[i]["events"] as? [NSDictionary] {
                    parsedResponse.events = []
                    for event in events {
                        parsedResponse.events!.append(SponsyEvent(dataDict: event))
                    }
                }
                if let sponsors = responses[i]["sponsors"] as? [NSDictionary] {
                    parsedResponse.sponsors = []
                    for sponsor in sponsors {
                        parsedResponse.sponsors!.append(SponsySponsor(dataDict: sponsor))
                    }
                }
                if let votings = responses[i]["votings"] as? [NSDictionary] {
                    parsedResponse.votings = []
                    for vote in votings {
                        parsedResponse.votings!.append(SponsyVote.init(dataDict: vote))
                    }
                }
                if let requests = responses[i]["requests"] as? [NSDictionary] {
                    parsedResponse.requests = []
                    for request in requests {
                        parsedResponse.requests!.append(SponsyRequest.init(dataDict: request))
                    }
                }
                if let detailedEventData = responses[i]["event_detailed"] as? NSDictionary {
                    parsedResponse.eventDataDetailed = SponsyEventDetailed.init(dataDict: detailedEventData)
                }
                if let detailedSponsorData = responses[i]["sponsor_detailed"] as? NSDictionary {
                    parsedResponse.sponsorDataDetailed = SponsySponsorDetailed.init(dataDict: detailedSponsorData)
                }
                if let dataEnd = responses[i]["data_end"] as? Bool {
                    parsedResponse.dataEnd = dataEnd
                }
                if let lastValue = responses[i]["last_value"] as? Double {
                    parsedResponse.lastValue = lastValue
                }
            case is HailySearchTask:
                if let searchResults = responses[i]["search_results"] as? [NSDictionary] {
                    let search_events_results = (requestTask as! HailySearchTask).searchType == HailySearchType.events
                    if search_events_results {
                        parsedResponse.events = []
                    }
                    else {
                        parsedResponse.sponsors = []
                    }
                    for searchResultDict in searchResults {
                        if search_events_results {
                            parsedResponse.events!.append(SponsyEvent(dataDict: searchResultDict))
                        }
                        else {
                            parsedResponse.sponsors!.append(SponsySponsor(dataDict: searchResultDict))
                        }
                    }
                }
            case is HailySyncTask:
                if let _error = responses[i]["error"] as? String {
                    parsedResponse.error = _error
                }
                if let _message = responses[i]["message"] as? String {
                    parsedResponse.message = _message
                }
                if let _new_messages_arrived = responses[i]["new_messages_arrived"] as? Bool {
                    parsedResponse.newMessagesArrived = _new_messages_arrived
                }
            case is HailyLoginTask:
                if let loginResultString = responses[i]["result"] as? String {
                    var login_result:HailyLoginResult!
                    if loginResultString == "ok" {
                        login_result = HailyLoginResult.ok
                    }
                    else {
                        login_result = HailyLoginResult.error
                    }
                    parsedResponse.loginResult = login_result
                }
                if let authToken = responses[i]["auth_token"] as? String {
                    UserDefaults().setValue(authToken, forKey: "auth_token")
                    General.authorized = true
                }
            case is HailyRegisterTask:
                if let registerResultString = responses[i]["result"] as? String {
                    var register_result:HailyRegisterResult!
                    if registerResultString == "ok" {
                        register_result = HailyRegisterResult.ok
                    }
                    else if registerResultString == "pass_error" {
                        register_result = HailyRegisterResult.passError
                    }
                    else if registerResultString == "same_email" {
                        register_result = HailyRegisterResult.alreadyRegistered
                    }
                    else {
                        register_result = HailyRegisterResult.error
                    }
                    parsedResponse.registerResult = register_result
                    if let authToken = responses[i]["auth_token"] as? String {
                        UserDefaults().setValue(authToken, forKey: "auth_token")
                        General.authorized = true
                    }
                }
            case is HailySuggestionTask:
                if let resultString = responses[i]["result"] as? String {
                    switch resultString {
                    case "ok" :
                        parsedResponse.result = HailyResponseResult.ok
                    default:
                        parsedResponse.result = HailyResponseResult.error
                    }
                }
            case is HailyVoteTask:
                if let resultString = responses[i]["result"] as? String {
                    switch resultString {
                    case "ok" :
                        parsedResponse.result = HailyResponseResult.ok
                    default:
                        parsedResponse.result = HailyResponseResult.error
                    }
                }
            case is HailyPutForVotingTask:
                if let resultString = responses[i]["result"] as? String {
                    switch resultString {
                    case "ok" :
                        parsedResponse.result = HailyResponseResult.ok
                    default:
                        parsedResponse.result = HailyResponseResult.error
                    }
                }
            default:
                continue
            }
            responsesParsed.append(parsedResponse)
        }
        return responsesParsed
    }
    
}

enum HailyResponseExploreState {
    case updated, ok, error
}

enum HailyResponseResult {
    case ban, ok, error, same, similar
}

enum HailyRegisterResponseResult {
    case ok, error, exists, absent, occupied
}

protocol HailyTask {
    
    func getDictionaryRepresentation() -> NSMutableDictionary
}

class HailyLoginTask : HailyTask {
    
    var pass = ""
    var email = ""
    
    init(email:String,pass:String) {
        self.email = email
        self.pass = pass
    }
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["email"] = email
        dict["pass"] = pass
        dict["taskType"] = "login"
        return dict
    }
    
}

class HailyRegisterTask : HailyTask {
    
    var pass = ""
    var email = ""
    
    init(email:String,pass:String) {
        self.email = email
        self.pass = pass
    }
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["email"] = email
        dict["pass"] = pass
        dict["taskType"] = "register"
        return dict
    }
    
}

class HailyPutForVotingTask : HailyTask {
    
    var partyId:Int = -1
    var partyType = ""
    
    init(partyId:Int,partyType:String) {
        self.partyId = partyId
        self.partyType = partyType
    }
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary();
        dict["party_id"] = partyId
        dict["party_type"] = partyType
        dict["taskType"] = "put_to_voting"
        return dict
    }
    
}

class HailyVoteTask : HailyTask {
    
    var voting_id:Int = -1
    var vote_yes:Bool = false
    
    init(voteId:Int, voteYes:Bool) {
        voting_id = voteId
        vote_yes = voteYes
    }
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["taskType"] = "vote"
        dict["vote_id"] = voting_id
        dict["vote_yes"] = vote_yes
        return dict
    }
}

class HailySuggestionTask : HailyTask {
    
    var suggestion:String = ""
    var destination_type:String = ""
    var destination_id:Int = -1
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["suggestion"] = suggestion
        dict["taskType"] = "suggest"
        dict["dest_type"] = destination_type
        dict["dest_id"] = destination_id
        return dict
    }
    
    init(type:String, id:Int,suggestionText:String) {
        suggestion = suggestionText
        destination_type = type
        destination_id = id
    }
    
}

class HailyReceiveTask : HailyTask {
    
    var dataOrigin:HailyDataOrigin!
    var dataType:HailyDataType!
    var lastId:Int?
    var sponsor_id:Int?
    var event_id:Int?
    
    init(dataOrigin:HailyDataOrigin,dataType:HailyDataType) {
       // super.init(taskType : HailyTaskType.Receive)
        self.dataOrigin = dataOrigin
        self.dataType = dataType
    }
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["taskType"] = "receive"
        var data_type_str = ""
        switch dataType! {
        case .all:
            data_type_str = "all"
        case .details:
            data_type_str = "details"
        case .incoming:
            data_type_str = "incoming"
        case .outgoing:
            data_type_str = "outgoing"
        case .own:
            data_type_str = "own"
        }
        dict["dataType"] = data_type_str
        var data_origin_str = ""
        switch dataOrigin! {
        case .event:
            data_origin_str = "event"
        case .sponsor:
            data_origin_str = "sponsor"
        case .request:
            data_origin_str = "request"
        case .vote:
            data_origin_str = "vote"
        }
        dict["dataOrigin"] = data_origin_str
        if let _last_id = lastId {
            dict["last_id"] = _last_id
        }
        if let _event_id = event_id {
            dict["event_id"] = _event_id
        }
        if let _sponsor_id = sponsor_id {
            dict["sponsor_id"] = _sponsor_id
        }
        return dict
    }
    
}

class HailySyncTask : HailyTask {
    
    init() {
        
    }
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["taskType"] = "sync"
        return dict
    }

}


class HailySearchTask : HailyTask {
    
    var searchText:String = ""
    var searchType:HailySearchType!
    
    init(searchType:HailySearchType, searchText:String) {
        self.searchType = searchType
        self.searchText = searchText
    }
    
    func getDictionaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["taskType"] = "search"
        dict["search_type"] = searchType == HailySearchType.events ? "events" : "sponsors"
        dict["search_text"] = searchText
        return dict
    }
    
}



enum HailyError : Error {
    
    case InternalError(String)
    case ExternalError(String?)
    
}

enum HailyLoginResult {
    case ok, error
}

enum HailyRegisterResult {
    case ok, error, alreadyRegistered, passError
}

enum HailyTaskBuilderStyle {
    case initial
}

enum HailyTaskType {
    case receive, sync, personal, search, create, post, register
}

enum HailyDataOrigin {
    case event,sponsor,request,vote
}

enum HailyDataType {
    case all, own, details, incoming, outgoing
}

enum HailyPersonalType {
    case feelings, reportTopic, reportOpinion, descriptionUpdate, discussionDisabledUpdate
}

enum HailySearchType {
    case events, sponsors
}

enum HailyCreateTopicPhase {
    case title, opinion
}

enum HailyRegisterPhase {
    case login, nickname
}
