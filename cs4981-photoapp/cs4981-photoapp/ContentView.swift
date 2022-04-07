//
//  ContentView.swift
//  cs4981-photoapp
//
//  Created by Bo-Chen Kuo on 12/7/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func test() -> Void{
    var test2 = UIImage()
    test2.jpegData(compressionQuality: <#T##CGFloat#>)
}
