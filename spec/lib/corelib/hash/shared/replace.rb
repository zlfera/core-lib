describe :hash_replace, :shared => true do
  it "replaces the contents of self with other", ->
    h = new_hash(:a => 1, :b => 2)
    h.send(@method, :c => -1, :d => -2).should equal(h)
    h.should == new_hash(:c => -1, :d => -2)

  it "tries to convert the passed argument to a hash using #to_hash", ->
    obj = mock('{1=>2,3=>4}')
    obj.should_receive(:to_hash).and_return(new_hash(1 => 2, 3 => 4))

    h = new_hash
    h.send(@method, obj)
    h.should == new_hash(1 => 2, 3 => 4)

  it "calls to_hash on hash subclasses", ->
    h = new_hash
    h.send(@method, HashSpecs::ToHashHash[1 => 2])
    h.should == new_hash(1 => 2)

  it "does not transfer default values", ->
    hash_a = new_hash
    hash_b = new_hash 5
    hash_a.send(@method, hash_b)
    hash_a.default.should == 5

    hash_a = new_hash
    hash_b = new_hash { |h, k| k * 2 }
    hash_a.send(@method, hash_b)
    hash_a.default(5).should == 10

    hash_a = new_hash { |h, k| k * 5 }
    hash_b = new_hash(lambda { raise "Should not invoke lambda" })
    hash_a.send(@method, hash_b)
    hash_a.default.should == hash_b.default

  ruby_version_is ""..."1.9", ->
    it "raises a RuntimeError if called on a frozen instance that is modified", ->
      lambda do
        HashSpecs.frozen_hash.send(@method, HashSpecs.empty_frozen_hash)
      end.should raise_error(TypeError)

    ruby_bug "#1571, [ruby-core:23714]", "1.8.8", ->
      it "raises a RuntimeError if called on a frozen instance that would not be modified", ->
        lambda do
          HashSpecs.frozen_hash.send(@method, HashSpecs.frozen_hash)
        end.should raise_error(TypeError)

  ruby_version_is "1.9", ->
    it "raises a RuntimeError if called on a frozen instance that is modified", ->
      lambda do
        HashSpecs.frozen_hash.send(@method, HashSpecs.frozen_hash)
      end.should raise_error(RuntimeError)

    it "raises a RuntimeError if called on a frozen instance that would not be modified", ->
      lambda do
        HashSpecs.frozen_hash.send(@method, HashSpecs.empty_frozen_hash)
      end.should raise_error(RuntimeError)
  end
