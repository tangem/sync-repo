//
//  ecmult_const_impl.swift
//  secp256k1
//
//  Created by pebble8888 on 2018/03/10.
//  Copyright © 2018年 pebble8888. All rights reserved.
//
/**********************************************************************
 * Copyright (c) 2015 Pieter Wuille, Andrew Poelstra                  *
 * Distributed under the MIT software license, see the accompanying   *
 * file COPYING or http://www.opensource.org/licenses/mit-license.php.*
 **********************************************************************/

import Foundation

let WNAF_BITS: Int = 256
func WNAF_SIZE(_ w: Int) -> Int {
    return ((WNAF_BITS + w - 1) / (w))
}

/* This is like `ECMULT_TABLE_GET_GE` but is constant time */
func ECMULT_CONST_TABLE_GET_GE(_ r: inout secp256k1_ge, _ pre: [secp256k1_ge],_ n: Int, _ w: UInt)
{
    let abs_n: UInt = UInt(n * (((n > 0) ? 1 : 0) * 2 - 1))
    let idx_n: UInt = abs_n / 2
    var neg_y = secp256k1_fe()
    VERIFY_CHECK(((n) & 1) == 1);
    VERIFY_CHECK((n) >= -((1 << ((w)-1)) - 1));
    VERIFY_CHECK((n) <=  ((1 << ((w)-1)) - 1));
#if VERIFY
    secp256k1_fe_clear(&r.x)
    secp256k1_fe_clear(&r.y)
#endif
    for m in 0 ..< ECMULT_TABLE_SIZE(Int(w)) {
        /* This loop is used to avoid secret data in array indices. See
         * the comment in ecmult_gen_impl.h for rationale. */
        secp256k1_fe_cmov(&r.x, pre[m].x, m == idx_n);
        secp256k1_fe_cmov(&r.y, pre[m].y, m == idx_n);
    }
    r.infinity = false
    secp256k1_fe_negate(&neg_y, r.y, 1);
    secp256k1_fe_cmov(&r.y, neg_y, (n) != abs_n);
}


/** Convert a number to WNAF notation.
 *  The number becomes represented by sum(2^{wi} * wnaf[i], i=0..WNAF_SIZE(w)+1) - return_val.
 *  It has the following guarantees:
 *  - each wnaf[i] an odd integer between -(1 << w) and (1 << w)
 *  - each wnaf[i] is nonzero
 *  - the number of words set is always WNAF_SIZE(w) + 1
 *
 *  Adapted from `The Width-w NAF Method Provides Small Memory and Fast Elliptic Scalar
 *  Multiplications Secure against Side Channel Attacks`, Okeya and Tagaki. M. Joye (Ed.)
 *  CT-RSA 2003, LNCS 2612, pp. 328-443, 2003. Springer-Verlagy Berlin Heidelberg 2003
 *
 *  Numbers reference steps of `Algorithm SPA-resistant Width-w NAF with Odd Scalar` on pp. 335
 */
func secp256k1_wnaf_const(_ wnaf: inout [Int], _ a_s: secp256k1_scalar,_ w: Int) -> Int {
    var s = a_s // ugly
    var global_sign: Int
    var skew: Int = 0;
    var word: Int = 0;
    
    /* 1 2 3 */
    var u_last:Int
    var u: Int = 0;
    
    var flip:Bool
    var bit:Bool
    var neg_s = secp256k1_scalar()
    var not_neg_one: Bool
    /* Note that we cannot handle even numbers by negating them to be odd, as is
     * done in other implementations, since if our scalars were specified to have
     * width < 256 for performance reasons, their negations would have width 256
     * and we'd lose any performance benefit. Instead, we use a technique from
     * Section 4.2 of the Okeya/Tagaki paper, which is to add either 1 (for even)
     * or 2 (for odd) to the number we are encoding, returning a skew value indicating
     * this, and having the caller compensate after doing the multiplication. */
    
    /* Negative numbers will be negated to keep their bit representation below the maximum width */
    flip = secp256k1_scalar_is_high(s);
    /* We add 1 to even numbers, 2 to odd ones, noting that negation flips parity */
    bit = (flip != !secp256k1_scalar_is_even(s))
    /* We check for negative one, since adding 2 to it will cause an overflow */
    secp256k1_scalar_negate(&neg_s, s);
    not_neg_one = !secp256k1_scalar_is_one(neg_s);
    secp256k1_scalar_cadd_bit(&s, bit ? 1 : 0, not_neg_one ? 1 : 0);
    /* If we had negative one, flip == 1, s.d[0] == 0, bit == 1, so caller expects
     * that we added two to it and flipped it. In fact for -1 these operations are
     * identical. We only flipped, but since skewing is required (in the sense that
     * the skew must be 1 or 2, never zero) and flipping is not, we need to change
     * our flags to claim that we only skewed. */
    global_sign = secp256k1_scalar_cond_negate(&s, flip ? 1 : 0);
    global_sign *= (not_neg_one ? 1 : 0) * 2 - 1;
    skew = 1 << (bit ? 1 : 0)
    
    /* 4 */
    u_last = Int(secp256k1_scalar_shr_int(&s, w))
    while (word * w < WNAF_BITS) {
        var sign:Int
        var even:Bool
        
        /* 4.1 4.4 */
        u = Int(secp256k1_scalar_shr_int(&s, w))
        /* 4.2 */
        even = ((u & 1) == 0);
        sign = 2 * (u_last > 0 ? 1 : 0) - 1;
        u += sign * (even ? 1 : 0)
        u_last -= sign * (even ? 1 : 0) * (1 << w);
        
        /* 4.3, adapted for global sign change */
        wnaf[word] = u_last * global_sign;
        word += 1
        
        u_last = u;
    }
    wnaf[word] = u * global_sign;
    
    VERIFY_CHECK(secp256k1_scalar_is_zero(s));
    VERIFY_CHECK(word == WNAF_SIZE(w));
    return skew
}


func secp256k1_ecmult_const(_ r: inout secp256k1_gej, _ a: secp256k1_ge, _ scalar: secp256k1_scalar) {
    var pre_a = [secp256k1_ge](repeating: secp256k1_ge(), count:ECMULT_TABLE_SIZE(WINDOW_A))
    var tmpa = secp256k1_ge()
    var Z = secp256k1_fe()
    
    var skew_1:Int
    var wnaf_1 = [Int](repeating: 0, count: 1 + Int(WNAF_SIZE(WINDOW_A - 1)))
    
    var i : Int
    let sc: secp256k1_scalar = scalar;
    
    /* build wnaf representation for q. */
    skew_1   = secp256k1_wnaf_const(&wnaf_1, sc, WINDOW_A - 1);
    
    /* Calculate odd multiples of a.
     * All multiples are brought to the same Z 'denominator', which is stored
     * in Z. Due to secp256k1' isomorphism we can do all operations pretending
     * that the Z coordinate was 1, use affine addition formulae, and correct
     * the Z coordinate of the result once at the end.
     */
    secp256k1_gej_set_ge(&r, a);
    secp256k1_ecmult_odd_multiples_table_globalz_windowa(&pre_a, &Z, r);
    i = 0
    while i < ECMULT_TABLE_SIZE(WINDOW_A) {
        secp256k1_fe_normalize_weak(&pre_a[i].y);
        i += 1
    }
    
    /* first loop iteration (separated out so we can directly set r, rather
     * than having it start at infinity, get doubled several times, then have
     * its new value added to it) */
    i = wnaf_1[Int(WNAF_SIZE(WINDOW_A - 1))];
    VERIFY_CHECK(i != 0);
    ECMULT_CONST_TABLE_GET_GE(&tmpa, pre_a, i, UInt(WINDOW_A));
    secp256k1_gej_set_ge(&r, tmpa);
    /* remaining loop iterations */
    i = Int(WNAF_SIZE(WINDOW_A - 1)) - 1
    while i >= 0 {
        var n:Int
        for _ in 0 ..< WINDOW_A - 1 {
            var dummy = secp256k1_fe()
            secp256k1_gej_double_nonzero(&r, r, &dummy)
        }
        
        n = wnaf_1[i];
        ECMULT_CONST_TABLE_GET_GE(&tmpa, pre_a, n, UInt(WINDOW_A));
        VERIFY_CHECK(n != 0);
        secp256k1_gej_add_ge(&r, r, tmpa);
        i -= 1
    }
    
    secp256k1_fe_mul(&r.z, r.z, Z);
    
    do {
        /* Correct for wNAF skew */
        var correction: secp256k1_ge = a
        var correction_1_stor = secp256k1_ge_storage()
        var a2_stor = secp256k1_ge_storage()
        var tmpj = secp256k1_gej()
        secp256k1_gej_set_ge(&tmpj, correction);
        var dummy = secp256k1_fe()
        secp256k1_gej_double_var(&tmpj, tmpj, &dummy);
        secp256k1_ge_set_gej(&correction, &tmpj);
        secp256k1_ge_to_storage(&correction_1_stor, a);
        secp256k1_ge_to_storage(&a2_stor, correction);
        
        /* For odd numbers this is 2a (so replace it), for even ones a (so no-op) */
        secp256k1_ge_storage_cmov(&correction_1_stor, a2_stor, skew_1 == 2);
        
        /* Apply the correction */
        secp256k1_ge_from_storage(&correction, correction_1_stor);
        secp256k1_ge_neg(&correction, correction);
        secp256k1_gej_add_ge(&r, r, correction);
        
    }
}
