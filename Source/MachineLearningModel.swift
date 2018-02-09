//
//  MachineLearningModel.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 1/11/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class MachineLearningModel: Mappable, RemovableArtikInstance {
    
    public enum ModelType: String {
        case prediction = "prediction"
        case anomalyDetection = "anomalyDetectionUsingPrediction"
    }
    
    public enum Status: String {
        case training = "training"
        case ready = "ready"
        case error = "error"
    }
    
    public class Source: Mappable {
        var did: String?
        var field: String?
        
        public init(did: String, field: String) {
            self.did = did
            self.field = field
        }
        
        public required init?(map: Map) {}
        
        public func mapping(map: Map) {
            did <- map["did"]
            field <- map["field"]
        }
    }
    
    public class InputOutput: Mappable {
        var name: String?
        var type: String?
        var value: String?
        var confidence: String?
        
        init(name: String, type: String) {
            self.name = name
            self.type = type
        }
        
        init(name: String, value: String, confidence: String? = nil) {
            self.name = name
            self.value = value
            self.confidence = confidence
        }
        
        public required init?(map: Map) {}
        
        public func mapping(map: Map) {
            name <- map["name"]
            type <- map["type"]
            value <- map["value"]
            confidence <- map["confidence"]
        }
    }
    
    public var id: String?
    public var uid: String?
    public var aid: String?
    public var inputs: [InputOutput]?
    public var outputs: [InputOutput]?
    public var sources: [Source]?
    public var trainingCron: String?
    public var type: ModelType?
    public var sourceToPredict: Source?
    public var anomalyDetectionSensitivity: UInt64?
    public var predictIn: UInt64?
    public var status: Status?
    public var origin: String?
    public var version: Int64?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        uid <- map["uid"]
        aid <- map["aid"]
        inputs <- map["inputs"]
        outputs <- map["outputs"]
        sources <- map["data.sources"]
        trainingCron <- map["trainingCron"]
        type <- map["type"]
        sourceToPredict <- map["parameters.sourceToPredict"]
        anomalyDetectionSensitivity <- map["parameters.anomalyDetectionSensitivity"]
        predictIn <- map["parameters.predictIn"]
        status <- map["status"]
        origin <- map["origin"]
        version <- map["version"]
    }
    
    public func predict(inputs: [InputOutput]) -> Promise<[InputOutput]> {
        let promise = Promise<[InputOutput]>.pending()
        
        if let id = id {
            MachineLearningAPI.predict(id: id, inputs: inputs).then { outputs -> Void in
                promise.fulfill(outputs)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    // MARK: - RemovableArtikInstance
    
    public func removeFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            MachineLearningAPI.delete(id: id).then { _ -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
}
