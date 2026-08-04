package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

var (
	fixPerlItemRegex = regexp.MustCompile(`.*quest::summonitem\((.*)\).*`)
	fixLuaItemRegex  = regexp.MustCompile(`.*other:SummonItem\((.*)\).*`)
	goodWriter       *os.File
	rcapocWriter     *os.File
	reviewWriter     *os.File
	goodList         map[int]bool = make(map[int]bool)
	rcApocList       map[int]bool = make(map[int]bool)
	missingList      map[int]bool = make(map[int]bool)
	duplicateList    map[int]bool = make(map[int]bool)
)

func main() {
	err := run()
	if err != nil {
		fmt.Println("failed run:", err)
		os.Exit(1)
	}
}

func run() error {
	err := loadMissing()
	if err != nil {
		return fmt.Errorf("loadMissing: %w", err)
	}
	err = loadDuplicate()
	if err != nil {
		return fmt.Errorf("loadDuplicate: %w", err)
	}
	err = loadRCApoc()
	if err != nil {
		return fmt.Errorf("loadRCApoc: %w", err)
	}

	goodWriter, err = os.Create("good.txt")
	if err != nil {
		return err
	}
	defer goodWriter.Close()

	rcapocWriter, err = os.Create("rcapoc.txt")
	if err != nil {
		return err
	}
	defer rcapocWriter.Close()

	reviewWriter, err = os.Create("review.txt")
	if err != nil {
		return err
	}
	defer reviewWriter.Close()

	err = filepath.Walk("../../Retribution/",
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			err = analyze(path)
			if err != nil {
				return fmt.Errorf("analyze %s: %w", path, err)
			}

			return nil
		})
	if err != nil {
		return fmt.Errorf("walk: %w", err)
	}

	return nil
}

func loadMissing() error {
	r, err := os.Open("../findapocdb/missing.txt")
	if err != nil {
		return err
	}
	defer r.Close()

	fs := bufio.NewScanner(r)
	fs.Split(bufio.ScanLines)

	lineNumber := 0
	for fs.Scan() {
		lineNumber++
		line := fs.Text()
		idx := strings.Index(line, ",")
		if idx < 0 {
			return fmt.Errorf("cannot find , on line %d in missing.txt", lineNumber)
		}
		id, err := strconv.Atoi(strings.TrimSpace(line[0:idx]))
		if err != nil {
			return fmt.Errorf("cannot atoi on line %d in missing.txt", lineNumber)
		}
		missingList[id] = true
	}
	return nil
}

func loadDuplicate() error {
	r, err := os.Open("../findapocdb/duplicate.txt")
	if err != nil {
		return err
	}
	defer r.Close()

	fs := bufio.NewScanner(r)
	fs.Split(bufio.ScanLines)

	lineNumber := 0
	for fs.Scan() {
		lineNumber++
		line := fs.Text()
		idx := strings.Index(line, ",")
		if idx < 0 {
			return fmt.Errorf("cannot find , on line %d in duplicate.txt", lineNumber)
		}
		id, err := strconv.Atoi(strings.TrimSpace(line[0:idx]))
		if err != nil {
			return fmt.Errorf("cannot atoi on line %d in duplicate.txt", lineNumber)
		}
		duplicateList[id] = true
		line = line[idx+1:]
		idx = strings.Index(line, ",")
		if idx < 0 {
			return fmt.Errorf("cannot find second , on line %d in duplicate.txt", lineNumber)
		}
		in := strings.TrimSpace(line[0:idx])
		id, err = strconv.Atoi(in)
		if err != nil {
			return fmt.Errorf("cannot atoi second entry on line %d in duplicate.txt: %s", lineNumber, in)
		}
		duplicateList[id] = true
	}
	return nil
}

func loadRCApoc() error {
	r, err := os.Open("../findapocdb/good.txt")
	if err != nil {
		return err
	}
	defer r.Close()

	fs := bufio.NewScanner(r)
	fs.Split(bufio.ScanLines)

	lineNumber := 0
	for fs.Scan() {
		lineNumber++
		line := fs.Text()
		idx := strings.Index(line, ",")
		if idx < 0 {
			return fmt.Errorf("cannot find , on line %d in good.txt", lineNumber)
		}
		id, err := strconv.Atoi(strings.TrimSpace(line[0:idx]))
		if err != nil {
			return fmt.Errorf("cannot atoi on line %d in good.txt", lineNumber)
		}
		goodList[id] = true

		line = line[idx+1:] //move to second entry
		idx = strings.Index(line, ",")
		id, err = strconv.Atoi(strings.TrimSpace(line[0:idx]))
		if err != nil {
			return fmt.Errorf("cannot atoi second , on line %d in good.txt", lineNumber)
		}
		rcApocList[id] = true

		line = line[idx+1:] //move to third entry
		idx = strings.Index(line, ",")
		if idx < 0 {
			return fmt.Errorf("cannot find third , on line %d in good.txt", lineNumber)
		}
		id, err = strconv.Atoi(strings.TrimSpace(line[0:idx]))
		if err != nil {
			return fmt.Errorf("cannot atoi second entry on line %d in good.txt", lineNumber)
		}
		rcApocList[id] = true
	}
	return nil
}

func analyze(path string) error {
	var err error
	switch filepath.Ext(path) {
	case ".pl":
	case ".lua":
	default:
		return nil
	}

	r, err := os.Open(path)
	if err != nil {
		return err
	}
	defer r.Close()
	fs := bufio.NewScanner(r)
	fs.Split(bufio.ScanLines)
	out := ""

	lineNumber := 0
	for fs.Scan() {
		lineNumber++
		line := fs.Text()
		switch filepath.Ext(path) {
		case ".pl":
			line, err = perlFix(path, line, lineNumber)
			if err != nil {
				return fmt.Errorf("perlFix: %w", err)
			}
		case ".lua":
			line, err = luaFix(path, line, lineNumber)
			if err != nil {
				return fmt.Errorf("luaFix: %w", err)
			}
		}
		out += line
	}
	//TODO: write file out
	return nil
}

func perlFix(path string, line string, lineNumber int) (string, error) {
	//quest::summonitem(29163);

	entries := fixPerlItemRegex.FindAllStringSubmatch(line, -1)
	if len(entries) < 1 {
		return line, nil
	}
	//entryIndexes := fixPerlItemRegex.FindAllStringSubmatchIndex(line, -1)
	for _, subEntries := range entries {
		for j, entry := range subEntries {
			if j == 0 { // 0 is the full line pattern match
				continue
			}
			intVal, err := strconv.Atoi(entry)
			if err != nil {
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %s is not a valid item (atoi failed)\n", path, lineNumber, entry))
				continue
			}
			isFound := false

			for id := range goodList {
				if intVal != id {
					continue
				}
				goodWriter.WriteString(fmt.Sprintf("%s:%d %d OK\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}
			for id := range rcApocList {
				if intVal != id {
					continue
				}
				rcapocWriter.WriteString(fmt.Sprintf("%s:%d %d is already an rcapoc item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}

			for id := range missingList {
				if intVal != id {
					continue
				}
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is not rc/apoc available item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}

			for id := range missingList {
				if intVal != id {
					continue
				}
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is a missing rc/apoc item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}
			for id := range duplicateList {
				if intVal != id {
					continue
				}
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is a duplicate rc/apoc item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}

			reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is an unhandled item\n", path, lineNumber, intVal))
		}
	}
	return line, nil
}

func luaFix(path string, line string, lineNumber int) (string, error) {
	//quest::summonitem(29163);

	entries := fixLuaItemRegex.FindAllStringSubmatch(line, -1)
	if len(entries) < 1 {
		return line, nil
	}
	//entryIndexes := fixPerlItemRegex.FindAllStringSubmatchIndex(line, -1)

	for _, subEntries := range entries {
		for j, entry := range subEntries {
			if j == 0 { // 0 is the full line pattern match
				continue
			}
			intVal, err := strconv.Atoi(entry)
			if err != nil {
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %s is not a valid item (atoi failed)\n", path, lineNumber, entry))
				continue
			}
			isFound := false

			for id := range goodList {
				if intVal != id {
					continue
				}
				goodWriter.WriteString(fmt.Sprintf("%s:%d %d OK\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}
			for id := range rcApocList {
				if intVal != id {
					continue
				}
				rcapocWriter.WriteString(fmt.Sprintf("%s:%d %d is already an rcapoc item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}

			for id := range missingList {
				if intVal != id {
					continue
				}
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is not rc/apoc available item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}

			for id := range missingList {
				if intVal != id {
					continue
				}
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is a missing rc/apoc item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}
			for id := range duplicateList {
				if intVal != id {
					continue
				}
				reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is a duplicate rc/apoc item\n", path, lineNumber, intVal))
				isFound = true
				break
			}
			if isFound {
				continue
			}

			reviewWriter.WriteString(fmt.Sprintf("%s:%d %d is an unhandled item\n", path, lineNumber, intVal))
		}
	}
	return line, nil
}
