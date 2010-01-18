require 'pp'

class Find
	def initialize(block)
		@include = []
		@exclude = []
		
		instance_eval &block
	end
	
	def include(files)
		@include += files
	end
	
	def exclude(files)
		@exclude += files
	end
	
	def find
		files = []
		@include.each do |path|
			if path =~ /\.\.\.\//
				(0...10).each do |i|
					files += Dir.glob(path.sub '.../', ('*/'*i))
				end
			else
				files += [path]
			end
		end
		
		files.map! do |file|
			if @exclude.map do |exclude|
						if file[0...exclude.size] == exclude then true
						else false
						end
					end.include? true
				nil
			else file
			end
		end
		files.compact
	end
end

def find(&block)
	Find.new(block).find
end

def boo(out, files=[], &block)
	if block != nil
		files += find &block
	end
	
	target = 
		if out =~ /\.dll$/ then 'library'
		elsif out =~ /\.win\.exe$/ then 'winexe'
		else 'exe'
		end
	
	references = files.map do |file|
			if file =~ /\.dll$/ then file
			else nil
			end
		end.compact
	
	files = files.map do |file|
			if references.include? file then nil
			else file
			end
		end.compact
	
	references.map! { |file| "-reference:#{file}" }
	
	file out => files do
		sh 'booc', "-o:#{out}", "-target:#{target}", *references, *files
	end
	Rake::Task[out].invoke
end

common = find do
		include [
				'Kernel/.../*.boo', 
				'Apps/.../*.boo', 
				'Library/.../*.boo', 
			]
		exclude [
				'Kernel/Platform', 
				'Kernel/Services/Platform', 
				'Apps/Platform', 
				'Library/Platform', 
			]
	end

task :default => [:hosted]

task :macros do
	boo 'Obj/Kernel.Macros.dll' do
		include ['Kernel/Macros/.../*.boo']
	end
end

task :hosted => [:macros] do
	boo 'Obj/Renraku.exe' do
		include common
		include [
				'Obj/Kernel.Macros.dll', 
				'SdlDotNet.dll', 
				
				'Kernel/Platform/Hosted/.../*.boo', 
				'Kernel/Services/Platform/Hosted/.../*.boo', 
				'Library/Platform/Hosted/.../*.boo', 
				'Apps/Platform/Hosted/.../*.boo', 
			]
	end
	
	sh 'corflags', '/32bit+', 'Obj/Renraku.exe'
end

task :ia32 => [:macros] do
	boo 'Obj/Core.dll' do
		include ['Core/.../*.boo']
	end
	
	boo 'Obj/Kernel.dll' do
		include common
		include [
				'Obj/Core.dll', 
				'Obj/Kernel.Macros.dll', 
				
				'Kernel/Platform/IA32/.../*.boo', 
				'Kernel/Services/Platform/IA32/.../*.boo', 
				'Library/Platform/IA32/.../*.boo', 
				'Apps/.../*.boo', 
			]
	end
end
