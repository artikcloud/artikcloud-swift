//
//  MachineLearningAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 1/11/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

open class MachineLearningAPI {
    
    // MARK: - Main Methods
    
    /// Creates a prediction model that learns a device's data usage.
    ///
    /// - Parameters:
    ///   - sources: Data source used in model.
    ///   - sourceToPredict: The device and field to be predicted by the model.
    ///   - predictIn: Time in seconds from last received data to predict output. Must be greater than 0.
    ///   - uid: (Optional) User ID. Required if using an application token.
    /// - Returns: A `Promise<MachineLearningModel>`
    open class func createPredictionModel(sources: [MachineLearningModel.Source], sourceToPredict: MachineLearningModel.Source, predictIn: UInt64, uid: String? = nil) -> Promise<MachineLearningModel> {
        if predictIn == 0 {
            let (promise, resolver) = Promise<MachineLearningModel>.pending()
            resolver.reject(ArtikError.machineLearning(reason: .invalidPredictIn))
            return promise
        }
        return create(sources: sources, sourceToPredict: sourceToPredict, predictIn: predictIn, uid: uid)
    }
    
    /// Creates an anomaly detection model that learns a device's data usage.
    ///
    /// - Parameters:
    ///   - sources: Data source used in model.
    ///   - sourceToPredict: The device and field to be predicted by the model.
    ///   - sensitivity: (Optional) Sensitivity of anomaly detection. Can be 0 (very few anomalies) to 100 (receive many anomalies). Defaults to 50.
    ///   - uid: (Optional) User ID. Required if using an application token.
    /// - Returns: A `Promise<MachineLearningModel>`
    open class func createAnomalyDetectionModel(sources: [MachineLearningModel.Source], sourceToPredict: MachineLearningModel.Source, anomalyDetectionSensitivity sensitivity: UInt64? = nil, uid: String? = nil) -> Promise<MachineLearningModel> {
        if let sensitivity = sensitivity, sensitivity > 100 {
            let (promise, resolve) = Promise<MachineLearningModel>.pending()
            resolve.reject(ArtikError.machineLearning(reason: .invalidSensitivity))
            return promise
        }
        return create(sources: sources, sourceToPredict: sourceToPredict, anomalyDetectionSensitivity: sensitivity, uid: uid)
    }
    
    /// Returns the predicted output for the specified input.
    ///
    /// - Parameters:
    ///   - id: The Model's id.
    ///   - inputs: Data input(s) to use in prediction, returned when creating a model.
    /// - Returns: A `Promise<[MachineLearningModel.InputOutput]>`.
    open class func predict(id: String, inputs: [MachineLearningModel.InputOutput]) -> Promise<[MachineLearningModel.InputOutput]> {
        let (promise, resolver) = Promise<[MachineLearningModel.InputOutput]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/ml/models/\(id)/predict"
        let parameters = [
            "inputs": inputs.toJSON()
        ]
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let outputsRaw = data["outputs"] as? [[String:Any]] {
                var outputs = [MachineLearningModel.InputOutput]()
                for outputRaw in outputsRaw {
                    if let output = MachineLearningModel.InputOutput(JSON: outputRaw) {
                        outputs.append(output)
                    } else {
                        resolver.reject(ArtikError.json(reason: .unexpectedFormat))
                    }
                }
                resolver.fulfill(outputs)
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get a Model.
    ///
    /// - Parameter id: The Model's id.
    /// - Returns: A `Promise<MachineLearningModel>`.
    open class func get(id: String) -> Promise<MachineLearningModel> {
        let (promise, resolver) = Promise<MachineLearningModel>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/ml/models/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let model = MachineLearningModel(JSON: data) {
                resolver.fulfill(model)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get all models of an application using pagination.
    ///
    /// - Parameters:
    ///   - count: Number of items returned per query, max `100`.
    ///   - offset: The offset used for pagination, default `0`.
    ///   - uid: (Optional) User ID. Required if using an application token.
    /// - Returns: A `Promise<Page<MachineLearningModel>>`.
    open class func get(count: Int, offset: Int = 0, uid: String? = nil) -> Promise<Page<MachineLearningModel>> {
        let (promise, resolver) = Promise<Page<MachineLearningModel>>.pending()
        let path = ArtikCloudSwiftSettings.basePath +  "/ml/models"
        var parameters: [String:Any] = [
            "count": count,
            "offset": offset,
        ]
        if let uid = uid {
            parameters["uid"] = uid
        }
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let modelsRaw = response["data"] as? [[String:Any]] {
                let page = Page<MachineLearningModel>(offset: offset, total: total)
                guard modelsRaw.count == Int(count) else {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in modelsRaw {
                    if let model = MachineLearningModel(JSON: item) {
                        page.data.append(model)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                resolver.fulfill(page)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get all models of an application using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameter uid: (Optional) User ID. Required if using an application token.
    /// - Returns: A `Promise<Page<MachineLearningModel>>`.
    open class func get(uid: String? = nil) -> Promise<Page<MachineLearningModel>> {
        return getRecursive(Page<MachineLearningModel>(), offset: 0, uid: uid)
    }
    
    /// Remove an existing model from ARTIK Cloud.
    ///
    /// - Parameter id: The Model's id.
    /// - Returns: A `Promise<Void>`.
    open class func delete(id: String) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/ml/models/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).done { _ in
            resolver.fulfill(())
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Helper Methods
    
    fileprivate class func create(sources: [MachineLearningModel.Source], sourceToPredict: MachineLearningModel.Source, predictIn: UInt64? = nil, anomalyDetectionSensitivity sensitivity: UInt64? = nil, uid: String? = nil) -> Promise<MachineLearningModel> {
        let (promise, resolver) = Promise<MachineLearningModel>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/ml/models"
        let parameters: [String:Any] = [
            "data": [
                "sources": sources.toJSON()
            ],
            "type": predictIn != nil ? MachineLearningModel.ModelType.prediction.rawValue : MachineLearningModel.ModelType.anomalyDetection.rawValue,
            "parameters": APIHelpers.removeNilParameters([
                "sourceToPredict": sourceToPredict.toJSON(),
                "predictIn": predictIn,
                "anomalyDetectionSensitivity": sensitivity
            ])
        ]
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let model = MachineLearningModel(JSON: data) {
                resolver.fulfill(model)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    fileprivate class func getRecursive(_ container: Page<MachineLearningModel>, offset: Int = 0, uid: String? = nil) -> Promise<Page<MachineLearningModel>> {
        let (promise, resolver) = Promise<Page<MachineLearningModel>>.pending()
        
        get(count: 100, offset: offset, uid: uid).done { result in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getRecursive(container, offset: Int(result.offset) + result.data.count, uid: uid).done { result in
                    resolver.fulfill(result)
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.fulfill(container)
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
}
