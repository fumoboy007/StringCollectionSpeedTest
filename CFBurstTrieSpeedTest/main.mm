#import <Foundation/Foundation.h>

#include <string>
#include <algorithm>
#include <iostream>

#include "CFBurstTrie.h"


using namespace std;


int main(int argc, const char * argv[]) {
	@autoreleasepool {
		CFBurstTrieRef burstTrie = CFBurstTrieCreate();
		NSMutableSet *set = [NSMutableSet set];
		
		
		NSString *wordList = [NSString stringWithContentsOfFile:@"/Users/darrenmo/Developer/Open Source/CFBurstTrieSpeedTest/CFBurstTrieSpeedTest/wordList.txt" encoding:NSUTF8StringEncoding error:NULL];
		
		__block clock_t burstTrieInsertElapsedTime = 0, setInsertElapsedTime = 0;
		
		[wordList enumerateLinesUsingBlock:^(NSString *word, BOOL *stop) {
			clock_t startTime, endTime;
			
			startTime = clock();
			CFBurstTrieAdd(burstTrie, (__bridge CFStringRef)word, CFRangeMake(0, [word length]), 0);
			endTime = clock();
			burstTrieInsertElapsedTime += endTime - startTime;
			
			startTime = clock();
			[set addObject:word];
			endTime = clock();
			setInsertElapsedTime += endTime - startTime;
		}];
		
		cout << "CFBurstTrie insert: " << (double)burstTrieInsertElapsedTime / CLOCKS_PER_SEC << " seconds" << endl;
		cout << "NSMutableSet insert: " << (double)setInsertElapsedTime / CLOCKS_PER_SEC << " seconds" << endl << endl;
		
		
		NSMutableArray *stringsToTest = [NSMutableArray array];
		
		const NSUInteger numStringsToTest = 1E6;
		string characters = "abcdefghijklmnopqrstuvwxyz";
		
		for (int length = 1; length <= characters.length(); length++) {
			for (int i = 0; i < numStringsToTest / characters.length(); i++) {
				random_shuffle(characters.begin(), characters.end());
				
				string substring = characters.substr(0, length);
				
				NSString *randomSubstring = [NSString stringWithCString:substring.c_str() encoding:NSASCIIStringEncoding];
				[stringsToTest addObject:randomSubstring];
			}
		}
		
		
		double burstTrieElapsedTime, setElapsedTime;
		clock_t startTime, endTime;
		
		
		startTime = clock();
		
		for (NSString *string in stringsToTest) {
			CFBurstTrieContains(burstTrie, (__bridge CFStringRef)string, CFRangeMake(0, [string length]), NULL);
		}
		
		endTime = clock();
		
		burstTrieElapsedTime = (double)(endTime - startTime) / CLOCKS_PER_SEC;
		
		
		startTime = clock();
		
		for (NSString *string in stringsToTest) {
			[set containsObject:string];
		}
		
		endTime = clock();
		
		setElapsedTime = (double)(endTime - startTime) / CLOCKS_PER_SEC;
		
		
		cout << "CFBurstTrie contains: " << burstTrieElapsedTime << " seconds" << endl;
		cout << "NSMutableSet contains: " << setElapsedTime << " seconds" << endl;
		
		
		CFRelease(burstTrie);
	}
	
    return EXIT_SUCCESS;
}

