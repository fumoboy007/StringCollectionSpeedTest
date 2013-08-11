#import <Foundation/Foundation.h>

#include <cassert>
#include <string>
#include <algorithm>
#include <iostream>
#include <unordered_set>
#include <vector>

#include "CFBurstTrie.h"
#include "NSString+CPPConversors.h"


using namespace std;


int main(int argc, const char * argv[]) {
	@autoreleasepool {
		CFBurstTrieRef burstTrie = CFBurstTrieCreate();
		NSMutableSet *cocoaSet = [NSMutableSet set];
		__block unordered_set<basic_string<unichar>> cppSet;
		
		
		NSString *wordList = [NSString stringWithContentsOfFile:@"/Users/darrenmo/Developer/Open Source/StringCollectionSpeedTest/StringCollectionSpeedTest/wordList.txt" encoding:NSUTF8StringEncoding error:NULL];
		
		__block clock_t burstTrieInsertElapsedTime = 0, cocoaSetInsertElapsedTime = 0, cppSetInsertElapsedTime = 0;
		
		[wordList enumerateLinesUsingBlock:^(NSString *word, BOOL *stop) {
			clock_t startTime, endTime;
			
			
			startTime = clock();
			
			bool success = CFBurstTrieAdd(burstTrie, (__bridge CFStringRef)word, CFRangeMake(0, [word length]), 1);
			
			endTime = clock();
			burstTrieInsertElapsedTime += endTime - startTime;
			
			assert(success);
			
			
			startTime = clock();
			
			[cocoaSet addObject:word];
			
			endTime = clock();
			cocoaSetInsertElapsedTime += endTime - startTime;
			
			
			basic_string<unichar> cppWord = [word cppString];
			
			startTime = clock();
			
			cppSet.insert(cppWord);
			
			endTime = clock();
			cppSetInsertElapsedTime += endTime - startTime;
		}];
		
		cout << "CFBurstTrie insert: " << (double)burstTrieInsertElapsedTime / CLOCKS_PER_SEC << " seconds" << endl;
		cout << "NSMutableSet insert: " << (double)cocoaSetInsertElapsedTime / CLOCKS_PER_SEC << " seconds" << endl;
		cout << "unordered_set insert: " << (double)cppSetInsertElapsedTime / CLOCKS_PER_SEC << " seconds" << endl << endl;
		
		
		for (NSString *word in cocoaSet) {
			assert(CFBurstTrieContains(burstTrie, (__bridge CFStringRef)word, CFRangeMake(0, [word length]), NULL));
		}
		
		
		NSMutableArray *stringsToTest = [NSMutableArray array];
		vector<basic_string<unichar>> cppStringsToTest;
		
		const NSUInteger numStringsToTest = 1E6;
		string characters = "abcdefghijklmnopqrstuvwxyz";
		
		for (int length = 1; length <= characters.length(); length++) {
			for (int i = 0; i < numStringsToTest / characters.length(); i++) {
				random_shuffle(characters.begin(), characters.end());
				
				string substring = characters.substr(0, length);
				
				NSString *randomSubstring = [NSString stringWithCString:substring.c_str() encoding:NSASCIIStringEncoding];
				
				[stringsToTest addObject:randomSubstring];
				cppStringsToTest.push_back([randomSubstring cppString]);
			}
		}
		
		
		double burstTrieElapsedTime, cocoaSetElapsedTime, cppSetElapsedTime;
		clock_t startTime, endTime;
		
		
		startTime = clock();
		
		for (NSString *string in stringsToTest) {
			CFBurstTrieContains(burstTrie, (__bridge CFStringRef)string, CFRangeMake(0, [string length]), NULL);
		}
		
		endTime = clock();
		
		burstTrieElapsedTime = (double)(endTime - startTime) / CLOCKS_PER_SEC;
		
		
		startTime = clock();
		
		for (NSString *string in stringsToTest) {
			[cocoaSet containsObject:string];
		}
		
		endTime = clock();
		
		cocoaSetElapsedTime = (double)(endTime - startTime) / CLOCKS_PER_SEC;
		
		
		startTime = clock();
		
		for (const auto& string : cppStringsToTest) {
			cppSet.count(string);
		}
		
		endTime = clock();
		
		cppSetElapsedTime = (double)(endTime - startTime) / CLOCKS_PER_SEC;
		
		
		cout << "CFBurstTrie contains: " << burstTrieElapsedTime << " seconds" << endl;
		cout << "NSMutableSet contains: " << cocoaSetElapsedTime << " seconds" << endl;
		cout << "unordered_set contains: " << cppSetElapsedTime << " seconds" << endl;
		
		
		CFRelease(burstTrie);
	}
	
    return EXIT_SUCCESS;
}

