set archivedTasks to ""
tell application "TaskPaper"
	tell front document
		-- don't care which file your log entry came from?
		-- comment the next line out
		set archivedTasks to "## " & name & return
		repeat with _task in search with query "project != Archive and @done"
			if entry type of _task is not project type then
				-- remove common tags that won't matter after archiving
				repeat with _tag in {"na", "next", "priority", "waiting"}
					if exists (tag named _tag of _task) then delete tag named _tag of _task
				end repeat
				-- if there's no project tag on the task, 
				-- add the task's current project as a tag
				if not (exists (tag named "project" of _task)) then
					tell _task to make tag with properties {name:"project", value:(name of containing project of _task as rich text)}
				end if
				-- collect notes for each task
				set taskNotes to ""
				repeat with _notes in _task
					set taskNotes to taskNotes & return & "     " & (text line of notes in _task) as rich text
				end repeat
				-- append the full text of the entry, including tags, and notes to our log
				set archivedTasks to archivedTasks & (text line of _task) & taskNotes
				-- archive it
				move entry id (id of _task) to beginning of entries of project "Archive"
			end if
		end repeat
	end tell
end tell
-- send the accumulated results to Day One via the command line tool
-- http://dayoneapp.com/faq/#commandlineinterface
-- You'll need to run `ln -s "/Applications/Day One/Day One.app/Contents/MacOS/dayone" /usr/local/bin/dayone` to have it accessible at this path
do shell script "echo " & (quoted form of archivedTasks) & " |tr -d \"\\t\"|/usr/local/bin/jrnl"