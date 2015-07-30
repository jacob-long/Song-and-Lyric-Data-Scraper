require 'tk'
require 'tkextlib/tile'


# noinspection RubyClassVariableUsageInspection,RubyResolve,RubyUnnecessarySemicolon
class Test

	def genre_buttons

		@@christcheck = TkVariable.new
		@@christb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'Christian';
		variable @@christcheck;
		onvalue 'christian';
		offvalue nil;
		}

		@@countcheck = TkVariable.new
		@@countb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'Country';
			variable @@countcheck;
			onvalue 'country';
			offvalue nil;
		}

		@@dancecheck = TkVariable.new
		@@danceb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'Dance/electronic';
			variable @@dancecheck;
			onvalue 'dance/electronic';
			offvalue nil;
		}

		@@latincheck = TkVariable.new
		@@latinb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'Latin';
		variable @@latincheck;
		onvalue 'latin';
		offvalue nil;
		}

		@@popcheck = TkVariable.new
		@@popb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'Pop';
			variable @@popcheck;
			onvalue 'pop';
			offvalue nil;
		}

		@@rbcheck = TkVariable.new
		@@rbb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'R&B/hip hop';
			variable @@rbcheck;
			onvalue 'R&B/hip hop';
			offvalue nil;
		}

		@@rapcheck = TkVariable.new
		@@rapb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'Rap';
			variable @@rapcheck;
			onvalue 'rap';
			offvalue nil
		}

		@@rockcheck = TkVariable.new
		@@rockb = Tk::Tile::CheckButton.new(@@g_selectors) {text 'Rock';
			variable @@rockcheck;
			onvalue 'rock';
			offvalue nil
		}

	end

	def year_entry

		@@tree_begin = Tk::Tile::Treeview.new(@@frame2){
			columns 'Year'
			yscrollcommand proc{|*args| @@scroll1.set(*args)}
		}

		@@scroll1 = Tk::Tile::Scrollbar.new(@@frame2) {orient 'vertical';
		command proc{|*args| @@tree_begin.yview(*args)}}.grid :column => 1, :row => 1

		@@tree_begin.configure('height' => '4', 'selectmode' => 'browse')

		@@tree_begin.show('')

		(2003...2015).each do |num|
			@@tree_begin.insert('', 'end', :id => "#{num}", :values => "#{num}")
		end

		@@tree_end = Tk::Tile::Treeview.new(@@frame2){
			columns 'Year'
			yscrollcommand proc{|*args| @@scroll2.set(*args)
		}

		@@scroll2 = Tk::Tile::Scrollbar.new(@@frame2) {orient 'vertical';
		command proc{|*args| @@tree_end.yview(*args)}}.grid :column => 1, :row => 3, :sticky => 'w'
		}

		@@tree_end.configure('height' => '4', 'selectmode' => 'browse')

		@@tree_end.show('')

		(2003...2015).each do |num|
			@@tree_end.insert('', 'end', :id => "#{num}", :values => "#{num}")
		end

	end

	def final_info

		@@begin_date = @@tree_begin.focus_item
		@@end_date = @@tree_end.focus_item
		p @@begin_date; p @@end_date

	end

	def save_DB_file

		filetypes = [["SQLite Databases", "*.sqlite"]]

		@@db_file_path = Tk::getSaveFile('filetypes' => filetypes)

	end

	def collect_genres
		@@selected_array = []
		[@@popcheck, @@rockcheck, @@rapcheck].each do |x|
			if x != nil
				@@selected_array.push(x.value)
			else
				next
			end
		end
		@@displayed_array = @@selected_array.join(', ')
		@@selected_display.configure('text' => @@displayed_array)
	end

	def initialize

		Tk::Tile::Style.theme_use 'aqua'

		@@selected_array = TkVariable.new
		@@selected_array = []

		@@root = TkRoot.new { title 'Testing app' }
		@@root['resizable'] = false, false

		@@tabs = Tk::Tile::Notebook.new(@@root)
		@@tabs.grid

		@@rootish = Tk::Tile::Frame.new(@@tabs)
		@@rootish.grid
		@@tabs.add

		@@g_selectors = Tk::Tile::Frame.new(@@rootish)
		@@g_selectors['padding'] = '10'

		collectgenres = proc {collect_genres; final_info}

		genre_buttons

		@@frame2 = Tk::Tile::Frame.new(@@rootish)
		# @@frame2['padding'] = '10'

		@@selected_display = Tk::Tile::Label.new(@@frame2){
			justify 'center'
			text 'Click the Selected button to see the genres'
			wraplength '200'
			anchor 'center'
		}

		@@butt_frame = Tk::Tile::Labelframe.new(@@rootish){
			text 'After selections are made:'
			padding '15'
		}

		@@scrape_button = Tk::Tile::Button.new(@@butt_frame) {
			text 'Scrape'
			command collectgenres
			grid :row => 0, :column => 0, :columnspan => 5, :sticky => 'ns'
		}

		Tk::Tile::Label.new(@@g_selectors) {
			text 'Select genres:'
			grid :column => 0, :row => 0, :pady => 7
		}

		Tk::Tile::Label.new(@@frame2) {
			justify 'center'
			text 'Choose the first year to scrape:'
			grid :column => 0, :row => 0, :pady => 7
		}

		Tk::Tile::Label.new(@@frame2) {
			justify 'center'
			text 'Choose the last year to scrape:'
			grid :column => 0, :row => 2, :pady => 7
		}

		choose_save_file = proc {save_DB_file}

		Tk::Tile::Label.new(@@frame2){
			text 'Choose where to save your database:'
			grid :column => 0, :row => 4, :pady => 10
		}

		Tk::Tile::Button.new(@@frame2){
			text 'Browse...'
			command choose_save_file
			grid :row => 5, :column => 0
		}

		year_entry

		Tk::Tile::Frame.new(@@tabs)

		# while ((@@christcheck != nil || @@countcheck != nil || @@dancecheck != nil || @@latincheck != nil || @@popcheck != nil || @@rbcheck != nil || @@rockcheck != nil || @@rapcheck != nil) && @@tree_begin.focus_item != nil && @@tree_end.focus_item != nil) == false
		# 	@@scrape_button.state('disabled')
		# # else
		# # 	@@scrape_button.state('disabled')
		# end

		@@g_selectors.grid :sticky => 'nsew', :columnspan => 3, :rowspan => 5
		@@butt_frame.grid :column => 0, :row => 5, :columnspan => 5, :pady => 15, :padx => 15, :sticky => 's'
		@@frame2.grid :column => 3, :row => 0, :padx => 15, :rowspan => 6, :sticky => 'ns'
		@@christb.grid :column => 0, :row => 1, :padx => 25, :pady => 5, :sticky => 'nw'
		@@countb.grid :column => 0, :row => 2, :padx => 25, :pady => 5, :sticky => 'nw'
		@@danceb.grid :column => 0, :row => 3, :padx => 25, :pady => 5, :sticky => 'nw'
		@@latinb.grid :column => 0, :row => 4, :padx => 25, :pady => 5, :sticky => 'nw'
		@@popb.grid :column => 0, :row => 5, :padx => 25, :pady => 5, :sticky => 'nw'
		@@rbb.grid :column => 0, :row => 6, :padx => 25, :pady => 5, :sticky => 'nw'
		@@rockb.grid :column => 0, :row => 7, :padx => 25, :pady => 5, :sticky => 'nw'
		@@rapb.grid :column => 0, :row => 8, :padx => 25, :pady => 5, :sticky => 'nw'
		@@tree_begin.grid :row => 1
		@@tree_end.grid :row => 3

		TkGrid.columnconfigure(@@butt_frame, 0, :weight => 5)
		TkGrid.rowconfigure(@@butt_frame, 5, :weight => 5)
		TkGrid.rowconfigure(@@scrape_button, 0, :weight => 5)

	end

end

Test.new
Tk.mainloop

