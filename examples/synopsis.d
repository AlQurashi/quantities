import std.math : approxEqual;
import quantities;

unittest
{
    import quantities;

    import std.math : approxEqual;
    import std.stdio : writeln, writefln;

    // ------------------
    // Working with units
    // ------------------

    // Define new units from the predefined ones (in module quantity.si)
    enum inch = 2.54 * centi(meter);
    enum mile = 1609 * meter;

    // Define new units with non-SI dimensions
    enum euro = unit!("€");
    enum dollar = euro / 1.35;

    // Default string representations
    writeln(meter);  // prints: 1 m
    writeln(inch);   // prints: 0.0254 m
    writeln(dollar); // prints: 0.740741 €
    writeln(volt);   // prints: 1 kg^-1 s^-3 m^2 A^-1 

    // -----------------------
    // Working with quantities
    // -----------------------

    // Use the predefined quantity types (in module quantity.si)
    MassicConcentration concentration;
    Volume volume;
    Mass mass;

    // I have to make a new solution at the concentration of 2.5 g/l.
    concentration = 2.5 * gram/liter;
    // The final volume is 10 ml.
    volume = 10 * milli(liter);
    // What mass should I weigh?
    mass = concentration * volume;
    writefln("Weigh %f kg of substance", mass.value(kilogram)); 
    // prints: Weigh 0.000025 kg of substance
    // Wait! My scales graduations are 0.1 milligrams!
    writefln("Weigh %.1f mg of substance", mass.value(milli(gram)));
    // prints: Weigh 25.0 mg of substance
    // I knew the result would be 25 mg.
    assert(mass.value(milli(gram)).approxEqual(25));

    // Type checking prevents incorrect assignments and operations
    static assert(!__traits(compiles, mass = 10 * milli(liter)));
    static assert(!__traits(compiles, concentration = 1 * euro/volume));

    // ----------------------------------------
    // Parsing quantities/units at compile-time
    // ----------------------------------------

    enum ctConcentration = qty!"2.5 g⋅L⁻¹";
    enum ctVolume = qty!"10 mL";
    enum ctMass = ctConcentration * ctVolume;
    static assert(ctMass.value(qty!"mg").approxEqual(25));


    // -----------------------------------
    // Parsing quantities/units at runtime
    // -----------------------------------

    mass = parseQuantity("25 mg");
    volume = parseQuantity("10 ml");
    concentration = parseQuantity("2.5 g⋅L⁻¹");
    auto targetUnit = qty!"kg/l";
    assert(concentration.value(targetUnit).approxEqual(0.0025));

    import std.exception;
    assertThrown!ParsingException(concentration = parseQuantity("10 qGz"));
    assertThrown!DimensionException(concentration = parseQuantity("2.5 mol⋅L⁻¹"));

    // User-defined symbols
    auto byte_ = unit!("B");
    SymbolList binSymbols;
    binSymbols.unitSymbols["B"] = byte_.toRuntime;
    binSymbols.prefixSymbols["Ki"] = 2^^10;
    binSymbols.prefixSymbols["Mi"] = 2^^20;
    // ...
    QuantityType!byte_ fileLength = parseQuantity("1.0 MiB", binSymbols);
    writefln("Length: %.0f bytes", fileLength.value(byte_));
    // prints: Length: 1048576 bytes
}