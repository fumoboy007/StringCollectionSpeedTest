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
			word = [word mutableCopy];
			
			
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
				
				NSString *randomSubstring = [NSMutableString stringWithCString:substring.c_str() encoding:NSASCIIStringEncoding];
				
				[stringsToTest addObject:randomSubstring];
				cppStringsToTest.push_back([randomSubstring cppString]);
			}
		}
		
		
		clock_t burstTrieSearchElapsedTime = 0, cocoaSetSearchElapsedTime = 0, cppSetSearchElapsedTime = 0;
		clock_t startTime = 0, endTime = 0;
		
		
		for (NSString *string in stringsToTest) {
			startTime = clock();
			
			CFBurstTrieContains(burstTrie, (__bridge CFStringRef)string, CFRangeMake(0, [string length]), NULL);
			
			endTime = clock();
			
			burstTrieSearchElapsedTime += endTime - startTime;
		}
		
		
		for (NSString *string in stringsToTest) {
			startTime = clock();
			
			[cocoaSet containsObject:string];
			
			endTime = clock();
			
			cocoaSetSearchElapsedTime += endTime - startTime;
		}
		
		
		for (const auto& string : cppStringsToTest) {
			startTime = clock();
			
			cppSet.count(string);
			
			endTime = clock();
			
			cppSetSearchElapsedTime += endTime - startTime;
		}
		
		
		cout << "CFBurstTrie search: " << (double)burstTrieSearchElapsedTime / CLOCKS_PER_SEC << " seconds" << endl;
		cout << "NSMutableSet search: " << (double)cocoaSetSearchElapsedTime / CLOCKS_PER_SEC << " seconds" << endl;
		cout << "unordered_set search: " << (double)cppSetSearchElapsedTime / CLOCKS_PER_SEC << " seconds" << endl;
		
		
		CFRelease(burstTrie);
	}
	
    return EXIT_SUCCESS;
}

