//
//  utils.swift
//  odin
//
//  Created by Manav Seksaria on 25/01/25.
//

import Foundation

struct Block: Codable {
    let name: String
    let blocks: [String]
}

//blocklist

func json() -> [Block]? {
  let fileName = "blocklist.json";


  let fileURL = URL(fileURLWithPath: fileName)
  
  do {
      let data = try Data(contentsOf: fileURL)
      var decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
      for (key, value) in decodedData {
        decodedData[key] = value.map { $0.lowercased() }
      }
    
    return Array(decodedData).map(Block.init)
    
  } catch {
      print("Error reading JSON: \(error)")
      return nil
  }
}
