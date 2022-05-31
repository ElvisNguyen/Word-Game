local vowels = {"a", "e", "i", "o", "u", "y"}
local consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r" ,"s", "t", "v", "w", "x", "z"}

local CONST_CONSONANT_BANK_SIZE = 13
local CONST_VOWEL_BANK_SIZE = 3

local consonant_bank = {}
local vowel_bank = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")



--Checks if a given word is a valid word in the English dictionary
function is_word (word)
	local HttpService = game:GetService("HttpService")
	local Dictionary_Endpoint = "https://api.dictionaryapi.dev/api/v2/entries/en/"..word
	
	local called_successfully, response  = pcall(function() HttpService:GetAsync(Dictionary_Endpoint) end)
	
	--[[
		Logic behind this is: 
		If the API returns a 404, then it's not a word, but if it throws an HTTP error that isn't,
		a 404, then we aren't certain if it's a word or not. Defaults to false.
	]]
	if called_successfully == false and response ~= "HTTP 404 (Not Found)" then
		warn("Request returned an error other than 404")
		return false
	end
	
	--If the API call was successful and did not return an error, it's a word
	if called_successfully == true and response == nil then
		return true
	end
	
	--Defaults to false if the above conditions are not hit
	return false
end



-- Returns a random vowel
function get_vowel()
	local number_of_vowels = #vowels
	
	-- Returns random vowel
	return vowels[math.random(1, number_of_vowels)]
end



--Returns a random consonant
function get_consonant()
	local number_of_consonants = #consonants
	
	-- Returns random consonant
	return consonants[math.random(1, number_of_consonants)]
end





-- Fills the letter banks with random vowels and consonants
function fill_letter_banks()
	while #vowel_bank < CONST_VOWEL_BANK_SIZE  do
		table.insert(vowel_bank, get_vowel() )
	end
	
	while #consonant_bank < CONST_CONSONANT_BANK_SIZE do
		table.insert(consonant_bank, get_consonant() )
	end
	
	table.sort(consonant_bank)
	table.sort(vowel_bank)
	
	print(vowel_bank)
	print(consonant_bank)
end


function check_word(player, word)
	if not is_word(word) then
		print(word.." is not a word")
		return false
	end
	
	local vowel_bank_copy = table.clone(vowel_bank)
	local consonant_bank_copy = table.clone(consonant_bank)
	--[[
		Goes through every letter of the word and if it is inside the word banks, removes it from a copy of the word bank
		If it cannot find the letter in the word bank, it returns false.
		AND
		If it makes it to the end of the function without returning false, it copies the copied banks with
		the removed words into the main banks and fills the empty slots.
	]]
	for i=1, #word do
		local letter = word:sub(i,i)
		
		if table.find(vowels, letter) ~= nil then
			local index = table.find(vowel_bank_copy, letter)
			
			if index == nil then
				--print("Index nil "..letter)
				return false
			else
				--print("Removed: "..letter)
				table.remove(vowel_bank_copy, index)
			end
		end	
		
		if table.find(consonants, letter) ~= nil then
			local index = table.find (consonant_bank_copy, letter)
			
			if index == nil then
				--print("Index nil "..letter)
				return false
			else
				--print("Removed: "..letter)
				table.remove(consonant_bank_copy, index)
			end
		end
	end
	
	vowel_bank = vowel_bank_copy
	consonant_bank = consonant_bank_copy
	fill_letter_banks(vowel_bank, consonant_bank)
	return true
end

fill_letter_banks()
remoteEvent.OnServerEvent:Connect(check_word)
